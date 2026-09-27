<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Batch;
use App\Models\Complaint;
use App\Models\ComplaintRemark;
use App\Models\ComplaintTimeline;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ComplaintController extends BaseApiController
{
    /**
     * List Complaints (Role-Aware & Filterable)
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Complaint::with(['student', 'currentHandler', 'timeline', 'remarks'])->latest();

        // 1. Role Scope Filter
        if ($request->boolean('my_complaints') || $user->role === 'student') {
            $query->where('student_id', $user->id);
        } elseif ($user->role === 'cr') {
            // CR can see own complaints or their section complaints
            $query->where(function ($q) use ($user) {
                $q->where('student_id', $user->id)
                  ->orWhere(function ($sq) use ($user) {
                      $sq->where('batch', $user->batch)->where('section', $user->section);
                  });
            });
        } elseif ($user->role === 'batch_adviser') {
            // Adviser sees complaints from their advised batch
            $batchNames = Batch::where('adviser_id', $user->id)->pluck('name')->toArray();
            if (!empty($batchNames)) {
                $query->where(function ($q) use ($batchNames, $user) {
                    $q->whereIn('batch', $batchNames)
                      ->orWhere('current_handler_id', $user->id);
                });
            } else {
                $query->where('current_handler_id', $user->id);
            }
        } elseif (in_array($user->role, ['coordinator', 'chairman', 'office_staff', 'dean', 'admin'])) {
            // Department leadership & office staff see all department complaints
        }

        // 2. Status Filter
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // 3. Priority Filter
        if ($request->filled('priority')) {
            $query->where('priority', $request->priority);
        }

        // 4. Category Filter
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // 5. Search Filter
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('tracking_number', 'like', "%{$search}%");
            });
        }

        $perPage = (int) $request->input('per_page', 15);
        $paginator = $query->paginate($perPage);

        return $this->paginated($paginator, fn(Complaint $c) => $c->toResponseArray());
    }

    /**
     * My Complaints Only
     */
    public function myComplaints(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Complaint::with(['student', 'currentHandler', 'timeline', 'remarks'])
            ->where('student_id', $user->id)
            ->latest();

        $perPage = (int) $request->input('per_page', 15);
        $paginator = $query->paginate($perPage);

        return $this->paginated($paginator, fn(Complaint $c) => $c->toResponseArray());
    }

    /**
     * Show Single Complaint Detail
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student', 'currentHandler', 'timeline', 'remarks'])->find($id);

        if (!$complaint) {
            return $this->error('Complaint record not found.', 404);
        }

        return $this->success($complaint->toResponseArray(), 'Complaint retrieved.');
    }

    /**
     * Lodge a New Complaint
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'category' => ['required', 'string'],
            'priority' => ['required', 'string', 'in:low,medium,high,urgent'],
            'batch' => ['nullable', 'string'],
            'section' => ['nullable', 'string'],
            'attachments' => ['nullable', 'array'],
            'attachments.*' => ['file', 'mimes:jpg,jpeg,png,pdf,doc,docx', 'max:5120'], // Max 5MB per file
        ]);

        if ($validator->fails()) {
            return $this->error('Validation error', 422, $validator->errors());
        }

        return DB::transaction(function () use ($request, $user) {
            // Generate unique tracking number (e.g. DCMS-2026-XXXX)
            $randomCode = strtoupper(Str::random(4)) . random_int(100, 999);
            $trackingNumber = 'DCMS-' . date('Y') . '-' . $randomCode;

            // Handle file attachments
            $attachmentUrls = [];
            if ($request->hasFile('attachments')) {
                foreach ($request->file('attachments') as $file) {
                    $path = $file->store('complaint_attachments', 'public');
                    $attachmentUrls[] = $path;
                }
            }

            // Find designated Batch Adviser for student's batch
            $batchName = $request->batch ?? $user->batch;
            $adviser = null;
            if ($batchName) {
                $batchRecord = Batch::where('name', $batchName)->first();
                if ($batchRecord && $batchRecord->adviser_id) {
                    $adviser = User::find($batchRecord->adviser_id);
                }
            }

            $complaint = Complaint::create([
                'tracking_number' => $trackingNumber,
                'title' => $request->title,
                'description' => $request->description,
                'category' => $request->category,
                'status' => 'submitted',
                'priority' => $request->priority,
                'student_id' => $user->id,
                'batch' => $batchName,
                'section' => $request->section ?? $user->section,
                'current_handler_role' => 'batch_adviser',
                'current_handler_id' => $adviser?->id,
                'attachment_urls' => $attachmentUrls,
            ]);

            // Initial Timeline Audit Entry
            ComplaintTimeline::create([
                'complaint_id' => $complaint->id,
                'actor_id' => $user->id,
                'actor_name' => $user->name,
                'actor_role' => $user->role,
                'action' => 'Submitted',
                'status_after' => 'submitted',
                'remarks' => 'Complaint lodged in DCMS and routed to Batch Adviser for initial review.',
            ]);

            // Dispatch Push Notification to Adviser
            if ($adviser) {
                FcmService::sendToUser(
                    $adviser,
                    "New Complaint #{$trackingNumber}",
                    "Student {$user->name} submitted a new {$request->priority} priority complaint: {$request->title}",
                    'complaint_lodged',
                    (string) $complaint->id
                );
            }

            return $this->success($complaint->load(['student', 'timeline'])->toResponseArray(), 'Complaint lodged successfully with tracking ID: ' . $trackingNumber, 201);
        });
    }

    /**
     * Forward Complaint to next authority (Coordinator, Chairman, Office Staff, Dean)
     */
    public function forward(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $validator = Validator::make($request->all(), [
            'targetRole' => ['required', 'string', 'in:batch_adviser,coordinator,chairman,office_staff,dean'],
            'remarks' => ['required', 'string', 'max:1000'],
        ]);

        if ($validator->fails()) {
            return $this->error('Validation error', 422, $validator->errors());
        }

        $user = $request->user();
        $targetRole = $request->targetRole;
        $statusMap = [
            'coordinator' => 'forwarded_to_coordinator',
            'chairman' => 'forwarded_to_chairman',
            'office_staff' => 'forwarded_to_office',
            'dean' => 'forwarded_to_dean',
            'batch_adviser' => 'under_review',
        ];
        $newStatus = $statusMap[$targetRole] ?? 'under_review';

        return DB::transaction(function () use ($complaint, $user, $targetRole, $newStatus, $request) {
            $complaint->status = $newStatus;
            $complaint->current_handler_role = $targetRole;
            // Target user assignment if available
            $targetUser = User::where('role', $targetRole)->first();
            $complaint->current_handler_id = $targetUser?->id;
            $complaint->save();

            // Timeline Audit Log
            ComplaintTimeline::create([
                'complaint_id' => $complaint->id,
                'actor_id' => $user->id,
                'actor_name' => $user->name,
                'actor_role' => $user->role,
                'action' => 'Forwarded',
                'status_after' => $newStatus,
                'remarks' => $request->remarks,
            ]);

            // Add as Remark too
            ComplaintRemark::create([
                'complaint_id' => $complaint->id,
                'author_id' => $user->id,
                'author_name' => $user->name,
                'author_role' => $user->role,
                'content' => "[Forwarded to " . ucfirst(str_replace('_', ' ', $targetRole)) . "]: " . $request->remarks,
                'is_official' => true,
            ]);

            // Notify Student
            if ($complaint->student) {
                FcmService::sendToUser(
                    $complaint->student,
                    "Complaint #{$complaint->tracking_number} Updated",
                    "Your complaint has been forwarded to " . ucfirst(str_replace('_', ' ', $targetRole)) . " for assessment.",
                    'complaint_forwarded',
                    (string) $complaint->id
                );
            }

            // Notify Next Handler
            if ($targetUser) {
                FcmService::sendToUser(
                    $targetUser,
                    "Action Required: Complaint #{$complaint->tracking_number}",
                    "{$user->name} forwarded complaint '{$complaint->title}' to you for evaluation.",
                    'complaint_action_required',
                    (string) $complaint->id
                );
            }

            return $this->success($complaint->fresh(['student', 'timeline', 'remarks'])->toResponseArray(), 'Complaint forwarded successfully.');
        });
    }

    /**
     * Resolve Complaint
     */
    public function resolve(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $validator = Validator::make($request->all(), [
            'remarks' => ['required', 'string', 'max:1000'],
        ]);

        if ($validator->fails()) {
            return $this->error('Resolution remarks are required.', 422, $validator->errors());
        }

        $user = $request->user();

        return DB::transaction(function () use ($complaint, $user, $request) {
            $complaint->status = 'resolved';
            $complaint->resolved_at = now();
            $complaint->save();

            ComplaintTimeline::create([
                'complaint_id' => $complaint->id,
                'actor_id' => $user->id,
                'actor_name' => $user->name,
                'actor_role' => $user->role,
                'action' => 'Resolved',
                'status_after' => 'resolved',
                'remarks' => $request->remarks,
            ]);

            ComplaintRemark::create([
                'complaint_id' => $complaint->id,
                'author_id' => $user->id,
                'author_name' => $user->name,
                'author_role' => $user->role,
                'content' => "[Resolved]: " . $request->remarks,
                'is_official' => true,
            ]);

            if ($complaint->student) {
                FcmService::sendToUser(
                    $complaint->student,
                    "Complaint #{$complaint->tracking_number} Resolved",
                    "Your grievance has been successfully resolved by {$user->name}. Remarks: {$request->remarks}",
                    'complaint_resolved',
                    (string) $complaint->id
                );
            }

            return $this->success($complaint->fresh(['student', 'timeline', 'remarks'])->toResponseArray(), 'Complaint marked as resolved.');
        });
    }

    /**
     * Reject Complaint
     */
    public function reject(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $validator = Validator::make($request->all(), [
            'remarks' => ['required', 'string', 'max:1000'],
        ]);

        if ($validator->fails()) {
            return $this->error('Rejection remarks are required.', 422, $validator->errors());
        }

        $user = $request->user();

        return DB::transaction(function () use ($complaint, $user, $request) {
            $complaint->status = 'rejected';
            $complaint->save();

            ComplaintTimeline::create([
                'complaint_id' => $complaint->id,
                'actor_id' => $user->id,
                'actor_name' => $user->name,
                'actor_role' => $user->role,
                'action' => 'Rejected',
                'status_after' => 'rejected',
                'remarks' => $request->remarks,
            ]);

            ComplaintRemark::create([
                'complaint_id' => $complaint->id,
                'author_id' => $user->id,
                'author_name' => $user->name,
                'author_role' => $user->role,
                'content' => "[Rejected]: " . $request->remarks,
                'is_official' => true,
            ]);

            if ($complaint->student) {
                FcmService::sendToUser(
                    $complaint->student,
                    "Complaint #{$complaint->tracking_number} Rejected",
                    "Your complaint was rejected by {$user->name}. Reason: {$request->remarks}",
                    'complaint_rejected',
                    (string) $complaint->id
                );
            }

            return $this->success($complaint->fresh(['student', 'timeline', 'remarks'])->toResponseArray(), 'Complaint marked as rejected.');
        });
    }

    /**
     * Return Complaint back (e.g. to Student for more info or to lower authority)
     */
    public function returnBack(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $validator = Validator::make($request->all(), [
            'remarks' => ['required', 'string', 'max:1000'],
        ]);

        if ($validator->fails()) {
            return $this->error('Return remarks are required.', 422, $validator->errors());
        }

        $user = $request->user();

        return DB::transaction(function () use ($complaint, $user, $request) {
            $complaint->status = 'returned';
            $complaint->current_handler_role = 'student';
            $complaint->current_handler_id = $complaint->student_id;
            $complaint->save();

            ComplaintTimeline::create([
                'complaint_id' => $complaint->id,
                'actor_id' => $user->id,
                'actor_name' => $user->name,
                'actor_role' => $user->role,
                'action' => 'Returned',
                'status_after' => 'returned',
                'remarks' => $request->remarks,
            ]);

            ComplaintRemark::create([
                'complaint_id' => $complaint->id,
                'author_id' => $user->id,
                'author_name' => $user->name,
                'author_role' => $user->role,
                'content' => "[Returned for Review]: " . $request->remarks,
                'is_official' => true,
            ]);

            if ($complaint->student) {
                FcmService::sendToUser(
                    $complaint->student,
                    "Action Needed: Complaint #{$complaint->tracking_number} Returned",
                    "{$user->name} returned your complaint with notes: {$request->remarks}",
                    'complaint_returned',
                    (string) $complaint->id
                );
            }

            return $this->success($complaint->fresh(['student', 'timeline', 'remarks'])->toResponseArray(), 'Complaint returned back.');
        });
    }

    /**
     * Add Remark to Complaint Thread
     */
    public function addRemark(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['student'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $validator = Validator::make($request->all(), [
            'content' => ['required', 'string', 'max:2000'],
            'isOfficial' => ['sometimes', 'boolean'],
            'is_official' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return $this->error('Remark content cannot be empty.', 422, $validator->errors());
        }

        $user = $request->user();
        $isOfficial = $request->boolean('isOfficial') || $request->boolean('is_official') || $user->isStaff();

        $remark = ComplaintRemark::create([
            'complaint_id' => $complaint->id,
            'author_id' => $user->id,
            'author_name' => $user->name,
            'author_role' => $user->role,
            'author_avatar_url' => $user->avatar ? url('storage/' . $user->avatar) : null,
            'content' => $request->content,
            'is_official' => $isOfficial,
        ]);

        // Notify Student if staff commented
        if ($user->id !== $complaint->student_id && $complaint->student) {
            FcmService::sendToUser(
                $complaint->student,
                "New Remark on Complaint #{$complaint->tracking_number}",
                "{$user->name} commented: " . Str::limit($request->content, 80),
                'remark_added',
                (string) $complaint->id
            );
        }

        return $this->success($remark->toResponseArray(), 'Remark posted successfully.', 201);
    }

    /**
     * Complaint Timeline Trail
     */
    public function timeline(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['timeline'])->find($id);
        if (!$complaint) return $this->error('Complaint not found.', 404);

        $timeline = $complaint->timeline->map(fn($t) => $t->toResponseArray())->toArray();
        return $this->success($timeline, 'Timeline retrieved.');
    }
}
