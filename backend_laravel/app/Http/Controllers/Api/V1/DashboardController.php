<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Batch;
use App\Models\Complaint;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends BaseApiController
{
    /**
     * Role-Adaptive Dashboard Statistics
     */
    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Complaint::query();

        // Scope query based on user role
        if ($user->role === 'student') {
            $query->where('student_id', $user->id);
        } elseif ($user->role === 'cr') {
            $query->where(function ($q) use ($user) {
                $q->where('student_id', $user->id)
                  ->orWhere(function ($sq) use ($user) {
                      $sq->where('batch', $user->batch)->where('section', $user->section);
                  });
            });
        } elseif ($user->role === 'batch_adviser') {
            $batchNames = Batch::where('adviser_id', $user->id)->pluck('name')->toArray();
            if (!empty($batchNames)) {
                $query->where(function ($q) use ($batchNames, $user) {
                    $q->whereIn('batch', $batchNames)
                      ->orWhere('current_handler_id', $user->id);
                });
            } else {
                $query->where('current_handler_id', $user->id);
            }
        }

        $allComplaints = $query->get();

        $total = $allComplaints->count();
        $pending = $allComplaints->where('status', 'submitted')->count();
        $forwarded = $allComplaints->filter(fn($c) => str_starts_with($c->status, 'forwarded_to_'))->count();
        $inProgress = $allComplaints->whereIn('status', ['under_review', 'returned'])->count();
        $resolved = $allComplaints->where('status', 'resolved')->count();
        $rejected = $allComplaints->where('status', 'rejected')->count();

        $recentComplaints = (clone $query)->with(['student', 'timeline', 'remarks'])
            ->latest()
            ->limit(5)
            ->get()
            ->map(fn(Complaint $c) => $c->toResponseArray())
            ->values()
            ->all();

        $response = [
            'totalComplaints' => $total,
            'total_complaints' => $total,
            'pendingComplaints' => $pending,
            'pending_complaints' => $pending,
            'forwardedComplaints' => $forwarded,
            'forwarded_complaints' => $forwarded,
            'inProgressComplaints' => $inProgress,
            'in_progress_complaints' => $inProgress,
            'resolvedComplaints' => $resolved,
            'resolved_complaints' => $resolved,
            'rejectedComplaints' => $rejected,
            'rejected_complaints' => $rejected,
            'recentComplaints' => $recentComplaints,
            'recent_complaints' => $recentComplaints,
        ];

        return $this->success($response, 'Dashboard statistics retrieved.');
    }

    /**
     * Department Analytics Breakdown
     */
    public function analytics(Request $request): JsonResponse
    {
        $byCategory = Complaint::selectRaw('category, count(*) as count')
            ->groupBy('category')
            ->get();

        $byPriority = Complaint::selectRaw('priority, count(*) as count')
            ->groupBy('priority')
            ->get();

        $byStatus = Complaint::selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->get();

        return $this->success([
            'categories' => $byCategory,
            'priorities' => $byPriority,
            'statuses' => $byStatus,
            'totalUsers' => User::count(),
            'totalStudents' => User::whereIn('role', ['student', 'cr'])->count(),
        ], 'Analytics data retrieved.');
    }
}
