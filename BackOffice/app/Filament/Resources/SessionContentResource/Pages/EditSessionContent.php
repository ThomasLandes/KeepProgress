<?php

namespace App\Filament\Resources\SessionContentResource\Pages;

use App\Filament\Resources\SessionContentResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSessionContent extends EditRecord
{
    protected static string $resource = SessionContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
