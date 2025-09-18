<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Exercise extends Model
{
    protected $table = 'exercises';
    protected $primaryKey = 'exercise_id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'exercise_name',
        'exercise_body_part',
        'exercise_description',
    ];
}
