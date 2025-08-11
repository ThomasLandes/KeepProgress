<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TrainingSession extends Model
{
    protected $table = 'training_sessions';
    protected $primaryKey = 'training_session_id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'user_id',
        'session_date',
        'duration',
    ];

    protected $casts = [
        'session_date' => 'datetime',
        'duration' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function contents(): HasMany
    {
        return $this->hasMany(SessionContent::class, 'training_session_id', 'training_session_id');
    }
}
