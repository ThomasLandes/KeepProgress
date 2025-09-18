<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Gym extends Model
{
    protected $table = 'gyms';
    protected $primaryKey = 'gym_id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'gym_name',
        'gym_address',
        'current_occupation',
        'max_person_capacity',
        'opening_hour',
        'closing_hour',
    ];

    protected $casts = [
        'current_occupation' => 'integer',
        'max_person_capacity' => 'integer',
        // opening_hour / closing_hour sont des TIME en DB : donc string (HH:MM:SS)
    ];


    public function isOpenNow(?string $time = null): ?bool
    {
        if (empty($this->opening_hour) || empty($this->closing_hour)) {
            return null;
        }
        $now = $time ?? date('H:i:s'); // attention au fuseau du serveur DB
        // Cas basique : horaires le même jour (08:00 -> 20:00)
        if ($this->opening_hour <= $this->closing_hour) {
            return $now >= $this->opening_hour && $now <= $this->closing_hour;
        }
        // Cas overnight (20:00 -> 06:00)
        return $now >= $this->opening_hour || $now <= $this->closing_hour;
    }
}
