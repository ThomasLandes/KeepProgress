<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ExerciseResource\Pages;
use App\Models\Exercise;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ExerciseResource extends Resource
{
    protected static ?string $model = Exercise::class;

    protected static ?string $navigationIcon = 'heroicon-o-bolt';
    protected static ?string $navigationLabel = 'Exercises';
    protected static ?string $modelLabel = 'Exercise';
    protected static ?string $pluralModelLabel = 'Exercises';
    protected static ?string $navigationGroup = 'Catalogue';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('exercise_name')
                ->label('Name')
                ->required()
                ->maxLength(255)
                ->unique(ignoreRecord: true),
            Forms\Components\Select::make('exercise_body_part')
                ->label('Groupe musculaire')
                ->options([
                    'chest' => 'Poitrine',
                    'back' => 'Dos',
                    'legs' => 'Jambes',
                    'shoulders' => 'Épaules',
                    'arms' => 'Bras',
                    'core' => 'Gainage',
                    'glutes' => 'Fessiers',
                    'full_body' => 'Full Body',
                    'other' => 'Autre',
                ]),
            Forms\Components\Textarea::make('exercise_description')
                ->label('Description')
                ->rows(5)
                ->maxLength(1000)
                ->nullable()
                ->columnSpanFull(),
        ])->columns(2);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('exercise_name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                // NEW: badge body part
                Tables\Columns\TextColumn::make('exercise_body_part')
                    ->label('Groupe')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('exercise_description')
                    ->label('Description')
                    ->limit(60)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->since()
                    ->label('Maj')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('exercise_body_part')
                    ->label('Groupe musculaire')
                    ->options([
                        'chest' => 'Poitrine',
                        'back' => 'Dos',
                        'legs' => 'Jambes',
                        'shoulders' => 'Épaules',
                        'arms' => 'Bras',
                        'core' => 'Gainage',
                        'glutes' => 'Fessiers',
                        'full_body' => 'Full Body',
                        'other' => 'Autre',
                    ]),
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
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListExercises::route('/'),
            'create' => Pages\CreateExercise::route('/create'),
            'edit' => Pages\EditExercise::route('/{record}/edit'),
            'view' => Pages\ViewExercise::route('/{record}'),
        ];
    }
}
