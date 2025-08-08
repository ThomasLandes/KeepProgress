<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasName;
use Filament\Panel;

class User extends Authenticatable implements FilamentUser, HasName
{
    use Notifiable;

    protected $table = 'users';
    protected $primaryKey = 'user_id';

    protected $fillable = [
        'user_name',
        'user_email',
        'user_password',
        'email_verified_at',
        'isAdmin',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'isAdmin' => 'boolean',
    ];

    public $timestamps = true;

    /**
     * Utilisé par Laravel Auth pour récupérer le hash du mot de passe.
     */
    public function getAuthPassword()
    {
        return $this->user_password;
    }

    /**
     * Optionnel : expose "email" si d'autres packages s'attendent à l'avoir.
     */
    public function getEmailAttribute()
    {
        return $this->user_email;
    }

    /**
     * Filament: contrôle qui peut accéder au panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->isAdmin === true;
    }

    /**
     * Filament: définit le nom affiché dans le header / menu utilisateur.
     */
    public function getFilamentName(): string
    {
        return $this->user_name ?: (string) $this->user_email;
    }
}
