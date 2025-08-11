<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Get;
use Filament\Forms\Form;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserResource extends \Filament\Resources\Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationLabel = 'Utilisateurs';
    protected static ?string $pluralLabel = 'Utilisateurs';
    protected static ?string $modelLabel = 'Utilisateur';
    protected static ?string $navigationGroup = 'Gestion';

    // Recherche globale dans la barre du haut
    public static function getGloballySearchableAttributes(): array
    {
        return ['user_name', 'user_email'];
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Identité')
                ->icon('heroicon-o-identification')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('user_name')
                        ->label('Nom')
                        ->required()
                        ->maxLength(255),

                    Forms\Components\TextInput::make('user_email')
                        ->label('Email')
                        ->email()
                        ->required()
                        ->unique(ignoreRecord: true, table: 'users', column: 'user_email'),
                ]),

            Forms\Components\Section::make('Sécurité')
                ->icon('heroicon-o-lock-closed')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('user_password') // champ virtuel
                    ->label('Mot de passe')
                        ->password()
                        ->revealable()
                        ->dehydrateStateUsing(fn ($state) => filled($state) ? Hash::make($state) : null)
                        ->dehydrated(fn ($state) => filled($state)) // n’envoie la valeur que si rempli
                        ->required(fn (Get $get, string $operation) => $operation === 'create')
                        ->helperText('Laisse vide pour ne pas modifier.'),

                    Forms\Components\Toggle::make('isAdmin')
                        ->label('Administrateur')
                        ->inline(false),
                ]),

            Forms\Components\Section::make('Métadonnées')
                ->columns(2)
                ->collapsible()
                ->schema([
                    Forms\Components\DateTimePicker::make('email_verified_at')
                        ->label('Email vérifié le')
                        ->native(false)
                        ->seconds(false),
                    Forms\Components\TextInput::make('remember_token')
                        ->label('Remember token')
                        ->maxLength(100)
                        ->helperText('Géré automatiquement lors du “remember me”.'),
                ]),
        ])
            ->columns(1);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user_name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable()
                    ->icon('heroicon-o-user'),

                Tables\Columns\TextColumn::make('user_email')
                    ->label('Email')
                    ->searchable()
                    ->sortable()
                    ->icon('heroicon-o-envelope'),

                Tables\Columns\TextColumn::make('isAdmin')
                    ->label('Rôle')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Admin' : 'User')
                    ->colors([
                        'success' => fn ($state) => $state === true,
                        'gray'    => fn ($state) => $state === false,
                    ])
                    ->icons([
                        'heroicon-o-shield-check' => fn ($state) => $state === true,
                        'heroicon-o-user'         => fn ($state) => $state === false,
                    ]),

                Tables\Columns\IconColumn::make('email_verified_at')
                    ->label('Email vérifié')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->tooltip(fn ($record) => $record->email_verified_at?->format('d/m/Y H:i')),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé')
                    ->since()
                    ->sortable(),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié')
                    ->since()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('isAdmin')
                    ->label('Admins seulement')
                    ->trueLabel('Admins')
                    ->falseLabel('Users')
                    ->placeholder('Tous'),

                Tables\Filters\TernaryFilter::make('email_verified_at')
                    ->label('Vérifiés')
                    ->boolean()
                    ->trueLabel('Vérifiés')
                    ->falseLabel('Non vérifiés')
                    ->placeholder('Tous'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make()
                    ->icon('heroicon-o-pencil-square'),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'view'   => Pages\ViewUser::route('/{record}'),
            'edit'   => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
