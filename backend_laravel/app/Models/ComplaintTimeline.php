<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ComplaintTimeline extends Model
{
    use HasFactory;

    protected $fillable = [
        'complaint_id',
        'actor_id',
        'actor_name',
        'actor_role',
        'action',
        'status_after',
        'remarks',
    ];

    public function complaint()
    {
        return $this->belongsTo(Complaint::class, 'complaint_id');
    }

    public function actor()
    {
        return $this->belongsTo(User::class, 'actor_id');
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'status' => $this->status_after,
            'status_after' => $this->status_after,
            'actorName' => $this->actor_name,
            'actor_name' => $this->actor_name,
            'actorRole' => $this->actor_role,
            'actor_role' => $this->actor_role,
            'action' => $this->action,
            'remarks' => $this->remarks,
            'createdAt' => $this->created_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
