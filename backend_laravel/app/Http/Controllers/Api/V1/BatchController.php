<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\AdviserMeetingRequest;
use App\Models\Batch;
use App\Models\Section;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BatchController extends BaseApiController
{
    /**
     * List all academic batches
     */
    public function index(): JsonResponse
    {
        $batches = Batch::with(['adviser', 'sections'])
            ->orderBy('year', 'asc')
            ->get()
            ->map(fn(Batch $b) => $b->toResponseArray())
            ->values()
            ->all();

        return $this->success($batches, 'Batches retrieved.');
    }

    /**
     * List sections for a batch
     */
    public function sections(Request $request): JsonResponse
    {
        $query = Section::with(['batch', 'cr']);
        if ($request->filled('batch_id')) {
            $query->where('batch_id', $request->batch_id);
        }

        $sections = $query->get();
        return $this->success($sections, 'Sections retrieved.');
    }

    /**
     * List Batch Advisers
     */
    public function advisers(): JsonResponse
    {
        $advisers = User::where('role', 'batch_adviser')
            ->get()
            ->map(fn(User $u) => $u->toResponseArray())
            ->values()
            ->all();

        return $this->success($advisers, 'Advisers retrieved.');
    }

    /**
     * Student Requests Meeting with Batch Adviser
     */
    public function requestAdviser(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'reason' => ['required', 'string', 'max:1000'],
            'preferredSlot' => ['nullable', 'string'],
            'preferred_slot' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->error('Meeting request reason is required.', 422, $validator->errors());
        }

        // Find batch adviser
        $batch = Batch::where('name', $user->batch)->first();
        $adviserId = $batch?->adviser_id;

        $meeting = AdviserMeetingRequest::create([
            'student_id' => $user->id,
            'adviser_id' => $adviserId,
            'reason' => $request->reason,
            'status' => 'pending',
            'preferred_slot' => $request->preferredSlot ?? $request->preferred_slot,
        ]);

        // Push notify adviser
        if ($adviserId) {
            $adviser = User::find($adviserId);
            if ($adviser) {
                FcmService::sendToUser(
                    $adviser,
                    'Meeting Request from Student',
                    "{$user->name} ({$user->reg_no}, Batch {$user->batch}) requested an appointment: {$request->reason}",
                    'meeting_request',
                    (string) $meeting->id
                );
            }
        }

        return $this->success($meeting, 'Meeting request submitted to your Batch Adviser.', 201);
    }
}
