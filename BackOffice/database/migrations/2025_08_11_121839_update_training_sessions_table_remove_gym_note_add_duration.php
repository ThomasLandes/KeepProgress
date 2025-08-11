<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('training_sessions', function (Blueprint $table) {
            if (Schema::hasColumn('training_sessions', 'gym_id')) {
                $table->dropForeign(['gym_id']);
                $table->dropColumn('gym_id');
            }
            if (Schema::hasColumn('training_sessions', 'session_note')) {
                $table->dropColumn('session_note');
            }
            if (! Schema::hasColumn('training_sessions', 'duration')) {
                $table->unsignedInteger('duration')->after('session_date');
            }
        });
    }

    public function down(): void
    {
        Schema::table('training_sessions', function (Blueprint $table) {
            // Rétablir les colonnes si besoin
            $table->unsignedBigInteger('gym_id')->nullable()->after('user_id');
            $table->text('session_note')->nullable()->after('session_date');
            $table->dropColumn('duration');

            // FK vers gyms
            $table->foreign('gym_id')
                ->references('gym_id')
                ->on('gyms')
                ->nullOnDelete();
        });
    }
};
