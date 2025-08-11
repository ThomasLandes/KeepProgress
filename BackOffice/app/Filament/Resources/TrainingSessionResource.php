<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TrainingSessionResource\Pages;
use App\Filament\Resources\TrainingSessionResource\RelationManagers\SessionContentsRelationManager;
use App\Models\TrainingSession;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TrainingSessionResource extends Resource
{
    protected static ?string $model = TrainingSession::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationLabel = 'Sessions';
    protected static ?string $modelLabel = 'Session';
    protected static ?string $pluralModelLabel = 'Sessions';
    protected static ?string $navigationGroup = 'Suivi';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('user_id')
                ->label('Utilisateur')
                ->relationship('user', 'user_name')
                ->searchable()->preload()->required(),

            Forms\Components\DateTimePicker::make('session_date')
                ->label('Date de session')
                ->seconds(false)
                ->required(),

            Forms\Components\TextInput::make('duration')
                ->label('Durée (min)')
                ->numeric()
                ->minValue(1)
                ->required(),
        ])->columns(2);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.user_name')->label('Utilisateur')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('session_date')->dateTime('Y-m-d H:i')->label('Date')->sortable(),
                Tables\Columns\TextColumn::make('duration')
                    ->label('Durée')
                    ->suffix(' min')
                    ->sortable(),
                Tables\Columns\TextColumn::make('contents_count')
                    ->counts('contents')
                    ->label('Exercices')
                    ->badge(),
                Tables\Columns\TextColumn::make('updated_at')->since()->label('Maj')->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\Filter::make('today')
                    ->label('Aujourd’hui')
                    ->query(fn ($q) => $q->whereDate('session_date', now()->toDateString())),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            SessionContentsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTrainingSessions::route('/'),
            'create' => Pages\CreateTrainingSession::route('/create'),
            'edit' => Pages\EditTrainingSession::route('/{record}/edit'),
            'view' => Pages\ViewTrainingSession::route('/{record}'),
        ];
    }
}
