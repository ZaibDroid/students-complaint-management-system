<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Complaint extends Model
{
    use HasFactory;

    protected $fillable = [
        'tracking_number',
        'title',
        'description',
        'category',
        'status',
        'priority',
        'student_id',
        'batch',
        'section',
        'current_handler_role',
        'current_handler_id',
        'attachment_urls',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'attachment_urls' => 'array',
            'resolved_at' => 'datetime',
        ];
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function currentHandler()
    {
        return $this->belongsTo(User::class, 'current_handler_id');
    }

    public function timeline()
    {
        return $this->hasMany(ComplaintTimeline::class, 'complaint_id')->orderBy('created_at', 'asc');
    }

    public function remarks()
    {
        return $this->hasMany(ComplaintRemark::class, 'complaint_id')->orderBy('created_at', 'asc');
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'trackingNumber' => $this->tracking_number,
            'tracking_number' => $this->tracking_number,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category,
            'status' => $this->status,
            'priority' => $this->priority,
            'studentId' => (string) $this->student_id,
            'studentName' => $this->student?->name ?? 'Unknown Student',
            'studentEmail' => $this->student?->email,
            'batch' => $this->batch ?? $this->student?->batch,
            'section' => $this->section ?? $this->student?->section,
            'currentHandlerRole' => $this->current_handler_role,
            'currentHandlerName' => $this->currentHandler?->name ?? ucfirst(str_replace('_', ' ', $this->current_handler_role)),
            'attachmentUrls' => array_map(function ($url) {
                return str_starts_with($url, 'http') ? $url : url('storage/' . $url);
            }, $this->attachment_urls ?? []),
            'timeline' => $this->timeline->map(fn($t) => $t->toResponseArray())->toArray(),
            'remarks' => $this->remarks->map(fn($r) => $r->toResponseArray())->toArray(),
            'createdAt' => $this->created_at?->toIso8601String(),
            'updatedAt' => $this->updated_at?->toIso8601String(),
            'resolvedAt' => $this->resolved_at?->toIso8601String(),
        ];
    }
}
