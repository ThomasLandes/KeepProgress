<?php

namespace App\Filament\Resources\TrainingSessionResource\RelationManagers;

use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Forms\Form;
use Filament\Tables;
use Filament\Tables\Table;

class SessionContentsRelationManager extends RelationManager
{
    protected static string $relationship = 'contents';
    protected static ?string $title = 'Exercices de la session';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('exercise_id')
                ->label('Exercice')
                ->relationship('exercise', 'exercise_name')
                ->searchable()->preload()->required(),

            Forms\Components\TextInput::make('sets')->numeric()->minValue(0)->label('Séries'),
            Forms\Components\TextInput::make('reps')->numeric()->minValue(0)->label('Répétitions'),
            Forms\Components\TextInput::make('weight')->numeric()->minValue(0)->label('Poids'),

        ])->columns(4);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('exercise.exercise_name')->label('Exercice')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('sets')->label('Séries')->sortable(),
                Tables\Columns\TextColumn::make('reps')->label('Répétitions')->sortable(),
                Tables\Columns\TextColumn::make('weight')->label('Poids')->sortable(),
                Tables\Columns\TextColumn::make('updated_at')->since()->label('Maj')->toggleable(isToggledHiddenByDefault: true),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('Ajouter'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }
}
