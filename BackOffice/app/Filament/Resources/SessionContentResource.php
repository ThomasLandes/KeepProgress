<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SessionContentResource\Pages;
use App\Models\SessionContent;
use App\Models\TrainingSession;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SessionContentResource extends Resource
{
    protected static ?string $model = SessionContent::class;

    protected static ?string $navigationIcon = 'heroicon-o-list-bullet';
    protected static ?string $navigationLabel = 'Lignes de séance';
    protected static ?string $modelLabel = 'Ligne de séance';
    protected static ?string $pluralModelLabel = 'Lignes de séance';
    protected static ?string $navigationGroup = 'Suivi';

    public static function form(Form $form): Form
    {
        return $form->schema([
            // Session : libellé lisible "YYYY-MM-DD HH:mm · User"
            Forms\Components\Select::make('training_session_id')
                ->label('Session')
                ->relationship('session', 'training_session_id')
                ->searchable()
                ->preload()
                ->required()
                ->getOptionLabelFromRecordUsing(function (TrainingSession $s) {
                    $date = optional($s->session_date)->format('Y-m-d H:i');
                    $user = optional($s->user)->user_name ?? '—';
                    return "{$date} · {$user}";
                }),

            Forms\Components\Select::make('exercise_id')
                ->label('Exercice')
                ->relationship('exercise', 'exercise_name')
                ->searchable()
                ->preload()
                ->required(),

            Forms\Components\TextInput::make('sets')
                ->label('Séries')
                ->numeric()
                ->minValue(0)
                ->required(),

            Forms\Components\TextInput::make('reps')
                ->label('Répétitions')
                ->numeric()
                ->minValue(0)
                ->required(),

            Forms\Components\TextInput::make('weight')
                ->label('Poids')
                ->numeric()
                ->minValue(0)
                ->step('0.5')
                ->suffix(' kg'),
        ])->columns(2);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('updated_at', 'desc')
            ->columns([
                Tables\Columns\TextColumn::make('session.user.user_name')
                    ->label('Utilisateur')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('session.session_date')
                    ->label('Date de session')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('exercise.exercise_name')
                    ->label('Exercice')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('sets')
                    ->label('Séries')
                    ->sortable(),

                Tables\Columns\TextColumn::make('reps')
                    ->label('Répétitions')
                    ->sortable(),

                Tables\Columns\TextColumn::make('weight')
                    ->label('Poids')
                    ->suffix(' kg')
                    ->sortable(),

                Tables\Columns\TextColumn::make('updated_at')
                    ->since()
                    ->label('Maj')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                // Par exercice
                SelectFilter::make('exercise_id')
                    ->label('Exercice')
                    ->relationship('exercise', 'exercise_name'),

                // Par utilisateur (via session.user)
                SelectFilter::make('user_id')
                    ->label('Utilisateur')
                    ->relationship('session.user', 'user_name'),

                // Par date (intervalle) sur la date de la session
                Filter::make('session_date_range')
                    ->label('Date de session')
                    ->form([
                        Forms\Components\DatePicker::make('from')->label('Du'),
                        Forms\Components\DatePicker::make('until')->label('Au'),
                    ])
                    ->query(function (Builder $query, array $data) {
                        return $query->whereHas('session', function (Builder $q) use ($data) {
                            $q->when($data['from'] ?? null, fn ($qq, $d) => $qq->whereDate('session_date', '>=', $d))
                                ->when($data['until'] ?? null, fn ($qq, $d) => $qq->whereDate('session_date', '<=', $d));
                        });
                    }),
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


    public static function getGloballySearchableAttributes(): array
    {
        return [
            'exercise.exercise_name',
            'session.user.user_name',
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSessionContents::route('/'),
            'create' => Pages\CreateSessionContent::route('/create'),
            'edit' => Pages\EditSessionContent::route('/{record}/edit'),
            'view' => Pages\ViewSessionContent::route('/{record}'),
        ];
    }
}
