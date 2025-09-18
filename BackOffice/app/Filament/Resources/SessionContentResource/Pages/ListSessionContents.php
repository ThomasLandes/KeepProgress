<?php

namespace App\Filament\Resources\SessionContentResource\Pages;

use App\Filament\Resources\SessionContentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSessionContents extends ListRecords
{
    protected static string $resource = SessionContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
