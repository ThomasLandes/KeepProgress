<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gyms', function (Blueprint $table) {
            // 1) Ajouter la nouvelle colonne gym_name si elle n’existe pas
            if (! Schema::hasColumn('gyms', 'gym_name')) {
                $table->string('gym_name')->nullable()->after('gym_id');
            }
        });

        // 2) Copier les données depuis gym_name_ si elle existe
        if (Schema::hasColumn('gyms', 'gym_name_')) {
            DB::statement('UPDATE gyms SET gym_name = gym_name_ WHERE gym_name IS NULL OR gym_name = ""');
        }

        Schema::table('gyms', function (Blueprint $table) {
            // 3) Rendre gym_name NOT NULL maintenant qu’elle est peuplée
            $table->string('gym_name')->nullable(false)->change();

            // 4) Supprimer l’ancienne colonne si présente
            if (Schema::hasColumn('gyms', 'gym_name_')) {
                $table->dropColumn('gym_name_');
            }

            // 5) Nouvelles colonnes
            if (! Schema::hasColumn('gyms', 'current_occupation')) {
                $table->unsignedInteger('current_occupation')->default(0)->after('gym_address');
            }
            if (! Schema::hasColumn('gyms', 'max_person_capacity')) {
                $table->unsignedInteger('max_person_capacity')->default(0)->after('current_occupation');
            }
            if (! Schema::hasColumn('gyms', 'opening_hour')) {
                $table->time('opening_hour')->nullable()->after('max_person_capacity');
            }
            if (! Schema::hasColumn('gyms', 'closing_hour')) {
                $table->time('closing_hour')->nullable()->after('opening_hour');
            }
        });
    }

    public function down(): void
    {
        Schema::table('gyms', function (Blueprint $table) {
            // Recréer l’ancienne colonne pour rollback
            if (! Schema::hasColumn('gyms', 'gym_name_')) {
                $table->string('gym_name_')->nullable()->after('gym_id');
            }
        });

        // Re-copier les données vers gym_name_ puis supprimer gym_name
        DB::statement('UPDATE gyms SET gym_name_ = gym_name');

        Schema::table('gyms', function (Blueprint $table) {
            if (Schema::hasColumn('gyms', 'gym_name')) {
                $table->dropColumn('gym_name');
            }
            if (Schema::hasColumn('gyms', 'closing_hour')) {
                $table->dropColumn('closing_hour');
            }
            if (Schema::hasColumn('gyms', 'opening_hour')) {
                $table->dropColumn('opening_hour');
            }
            if (Schema::hasColumn('gyms', 'max_person_capacity')) {
                $table->dropColumn('max_person_capacity');
            }
            if (Schema::hasColumn('gyms', 'current_occupation')) {
                $table->dropColumn('current_occupation');
            }
        });
    }
};
