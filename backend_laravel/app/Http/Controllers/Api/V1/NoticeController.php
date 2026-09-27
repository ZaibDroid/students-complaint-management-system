<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Notice;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class NoticeController extends BaseApiController
{
    /**
     * List Notices (Target Filtered & Pinned first)
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Notice::with('author')
            ->orderBy('is_pinned', 'desc')
            ->latest();

        // Target audience filtering for students
        if ($user->role === 'student' || $user->role === 'cr') {
            $query->where(function ($q) use ($user) {
                $q->where('target', 'all');
                if ($user->batch) {
                    $q->orWhere(function ($sq) use ($user) {
                        $sq->where('target', 'batch')->where('target_value', $user->batch);
                    });
                }
                if ($user->section) {
                    $q->orWhere(function ($sq) use ($user) {
                        $sq->where('target', 'section')->where('target_value', $user->section);
                    });
                }
            });
        }

        if ($request->filled('target')) {
            $query->where('target', $request->target);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('content', 'like', "%{$search}%");
            });
        }

        $notices = $query->get()->map(fn(Notice $n) => $n->toResponseArray())->values()->all();

        return $this->success($notices, 'Notices retrieved.');
    }

    /**
     * Show Notice Detail
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $notice = Notice::with('author')->find($id);
        if (!$notice) {
            return $this->error('Notice not found.', 404);
        }

        return $this->success($notice->toResponseArray(), 'Notice retrieved.');
    }

    /**
     * Publish a Notice
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role === 'student') {
            return $this->error('Only department staff and authorities can publish notices.', 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'target' => ['required', 'string', 'in:all,year,batch,section'],
            'targetValue' => ['nullable', 'string'],
            'target_value' => ['nullable', 'string'],
            'isPinned' => ['sometimes', 'boolean'],
            'is_pinned' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return $this->error('Validation error', 422, $validator->errors());
        }

        $notice = Notice::create([
            'title' => $request->title,
            'content' => $request->content,
            'target' => $request->target,
            'target_value' => $request->targetValue ?? $request->target_value,
            'author_id' => $user->id,
            'author_name' => $user->name,
            'author_role' => $user->role,
            'is_pinned' => $request->boolean('isPinned') || $request->boolean('is_pinned'),
        ]);

        // Push notification broadcast to targeted students
        $targetDesc = $request->target === 'all' ? 'All CS Students' : "{$request->target} " . ($request->targetValue ?? $request->target_value);
        if ($request->target === 'batch' && !empty($notice->target_value)) {
            FcmService::sendToBatch($notice->target_value, "New Notice: {$notice->title}", $notice->content, 'notice', (string) $notice->id);
        } else {
            $students = User::whereIn('role', ['student', 'cr'])->get();
            foreach ($students as $student) {
                FcmService::sendToUser($student, "Department Circular: {$notice->title}", $notice->content, 'notice', (string) $notice->id);
            }
        }

        return $this->success($notice->toResponseArray(), 'Notice published successfully.', 201);
    }

    /**
     * Delete Notice
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $notice = Notice::find($id);
        if (!$notice) {
            return $this->error('Notice not found.', 404);
        }

        $user = $request->user();
        if ($user->role !== 'admin' && $notice->author_id !== $user->id) {
            return $this->error('Unauthorized to delete this notice.', 403);
        }

        $notice->delete();
        return $this->success(null, 'Notice deleted successfully.');
    }
}
