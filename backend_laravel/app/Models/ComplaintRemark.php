<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ComplaintRemark extends Model
{
    use HasFactory;

    protected $fillable = [
        'complaint_id',
        'author_id',
        'author_name',
        'author_role',
        'author_avatar_url',
        'content',
        'is_official',
    ];

    protected function casts(): array
    {
        return [
            'is_official' => 'boolean',
        ];
    }

    public function complaint()
    {
        return $this->belongsTo(Complaint::class, 'complaint_id');
    }

    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'complaintId' => (string) $this->complaint_id,
            'complaint_id' => (string) $this->complaint_id,
            'authorId' => (string) $this->author_id,
            'author_id' => (string) $this->author_id,
            'authorName' => $this->author_name,
            'author_name' => $this->author_name,
            'authorRole' => $this->author_role,
            'author_role' => $this->author_role,
            'authorAvatarUrl' => $this->author_avatar_url,
            'content' => $this->content,
            'isOfficial' => (bool) $this->is_official,
            'is_official' => (bool) $this->is_official,
            'createdAt' => $this->created_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
