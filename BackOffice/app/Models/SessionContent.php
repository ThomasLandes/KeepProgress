<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SessionContent extends Model
{
    protected $table = 'session_content';
    protected $primaryKey = 'session_content_id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'training_session_id',
        'exercise_id',
        'reps',
        'sets',
        'weight',
    ];

    protected $casts = [
        'reps' => 'integer',
        'sets' => 'integer',
        'weight' => 'float',
    ];

    public function session(): BelongsTo
    {
        return $this->belongsTo(TrainingSession::class, 'training_session_id', 'training_session_id');
    }

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class, 'exercise_id', 'exercise_id');
    }
}
