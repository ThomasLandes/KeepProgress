<?php

namespace App\Filament\Resources;

use App\Filament\Resources\GymResource\Pages;
use App\Models\Gym;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class GymResource extends Resource
{
    protected static ?string $model = Gym::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office';
    protected static ?string $navigationLabel = 'Salles';
    protected static ?string $modelLabel = 'Salle';
    protected static ?string $pluralModelLabel = 'Salles';
    protected static ?string $navigationGroup = 'Catalogue';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('gym_name')
                ->label('Nom de la salle')
                ->required()
                ->maxLength(255)
                ->unique(ignoreRecord: true),

            Forms\Components\Textarea::make('gym_address')
                ->label('Adresse')
                ->rows(3)
                ->columnSpanFull(),

            Forms\Components\TextInput::make('max_person_capacity')
                ->label('Capacité max')
                ->numeric()
                ->minValue(0)
                ->required()
                ->reactive(),

            Forms\Components\TextInput::make('current_occupation')
                ->label('Occupation actuelle')
                ->numeric()
                ->minValue(0),

            Forms\Components\TimePicker::make('opening_hour')
                ->label('Ouverture')
                ->seconds(false)
                ->nullable(),

            Forms\Components\TimePicker::make('closing_hour')
                ->label('Fermeture')
                ->seconds(false)
                ->nullable(),
        ])->columns(2);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('gym_name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('gym_address')
                    ->label('Adresse')
                    ->limit(50)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('current_occupation')
                    ->label('Occup.')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('max_person_capacity')
                    ->label('Capacité')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('opening_hour')
                    ->label('Ouv.')
                    ->sortable(),

                Tables\Columns\TextColumn::make('closing_hour')
                    ->label('Ferm.')
                    ->sortable(),

                Tables\Columns\TextColumn::make('updated_at')
                    ->since()
                    ->label('Maj')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                // Filtre “Ouvert maintenant” simple (DB time)
                Filter::make('open_now')
                    ->label('Ouvert maintenant')
                    ->query(function (Builder $query) {
                        // Cas simple: ouverture < fermeture (journée)
                        // NB: si tu gères des horaires overnight, on peut faire plus poussé en SQL
                        return $query->whereNotNull('opening_hour')
                            ->whereNotNull('closing_hour')
                            ->whereRaw('TIME(NOW()) BETWEEN opening_hour AND closing_hour');
                    }),

                // Filtre "À capacité" (occupation >= 90% cap)
                Filter::make('almost_full')
                    ->label('Quasi plein (≥ 90%)')
                    ->query(fn (Builder $q) =>
                    $q->whereColumn('current_occupation', '>=', DB::raw('0.9 * max_person_capacity'))
                    ),
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
            'index' => Pages\ListGyms::route('/'),
            'create' => Pages\CreateGym::route('/create'),
            'edit' => Pages\EditGym::route('/{record}/edit'),
            'view' => Pages\ViewGym::route('/{record}'),
        ];
    }
}
