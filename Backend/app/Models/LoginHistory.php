<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoginHistory extends Model
{
    protected $guarded = [];
    public $timestamps = false; // We use login_at and logout_at

    protected $casts = [
        'login_at' => 'datetime',
        'logout_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
