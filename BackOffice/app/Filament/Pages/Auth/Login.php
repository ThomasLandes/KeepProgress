<?php

namespace App\Filament\Pages\Auth;

use Filament\Pages\Auth\Login as BaseLogin;

class Login extends BaseLogin
{
    /**
     * Mappe les champs du formulaire Filament vers tes colonnes SQL.
     * Filament va faire auth()->attempt() avec ce tableau.
     */
    protected function getCredentialsFromFormData(array $data): array
    {
        return [
            'user_email' => $data['email'],   // <-- clé SQL correcte
            'password'   => $data['password'],// utilisé pour la vérif de hash
        ];
    }
}
