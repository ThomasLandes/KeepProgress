<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ExerciseResource\Pages;
use App\Filament\Resources\ExerciseResource\RelationManagers;
use App\Models\Exercise;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Forms\Components\Select;



class ExerciseResource extends Resource
{
    protected static ?string $model = Exercise::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('name')
                    ->label('Nom de l’exercice')
                    ->required(),

                Textarea::make('description')
                    ->label('Description')
                    ->rows(3),

                Select::make('category')
                    ->label('Catégorie')
                    ->options([
                        'Musculation' => '💪 Musculation',
                        'Cardio' => '❤️ Cardio',
                        'HIIT' => '🔥 HIIT',
                        'Gainage' => '🧘 Gainage',
                        'Abdos' => '🌀 Abdos',
                    ])
                    ->required()
                    ->native(false), // rend le menu plus stylé dans Filament
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('category')
                    ->label('Catégorie')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'Musculation' => '💪 Musculation',
                        'Cardio' => '❤️ Cardio',
                        'HIIT' => '🔥 HIIT',
                        'Gainage' => '🧘 Gainage',
                        'Abdos' => '🌀 Abdos',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Musculation' => 'primary',
                        'Cardio' => 'success',
                        'HIIT' => 'danger',
                        'Gainage' => 'warning',
                        'Abdos' => 'gray',
                        default => 'secondary',
                    })
                    ->sortable(),


                TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('category')
                    ->label('Filtrer par catégorie')
                    ->options([
                        'Musculation' => 'Musculation',
                        'Cardio' => 'Cardio',
                        'HIIT' => 'HIIT',
                        'Gainage' => 'Gainage',
                        'Abdos' => 'Abdos',
                    ])
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListExercises::route('/'),
            'create' => Pages\CreateExercise::route('/create'),
            'edit' => Pages\EditExercise::route('/{record}/edit'),
        ];
    }
}
