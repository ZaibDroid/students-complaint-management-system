<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notice extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'target',
        'target_value',
        'author_id',
        'author_name',
        'author_role',
        'is_pinned',
        'attachment_url',
    ];

    protected function casts(): array
    {
        return [
            'is_pinned' => 'boolean',
        ];
    }

    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'title' => $this->title,
            'content' => $this->content,
            'target' => $this->target,
            'targetValue' => $this->target_value,
            'target_value' => $this->target_value,
            'authorId' => (string) $this->author_id,
            'author_id' => (string) $this->author_id,
            'authorName' => $this->author_name,
            'author_name' => $this->author_name,
            'authorRole' => $this->author_role,
            'author_role' => $this->author_role,
            'isPinned' => (bool) $this->is_pinned,
            'is_pinned' => (bool) $this->is_pinned,
            'attachmentUrl' => $this->attachment_url ? (str_starts_with($this->attachment_url, 'http') ? $this->attachment_url : url('storage/' . $this->attachment_url)) : null,
            'createdAt' => $this->created_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
