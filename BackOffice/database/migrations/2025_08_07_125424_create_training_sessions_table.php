<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// database/migrations/2024_08_07_100030_create_training_sessions_table.php
return new class extends Migration {
    public function up(): void
    {
        Schema::create('training_sessions', function (Blueprint $table) {
            $table->bigIncrements('training_session_id');
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('gym_id')->nullable();
            $table->dateTime('session_date');
            $table->string('session_note')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->onDelete('cascade');
            $table->foreign('gym_id')->references('gym_id')->on('gyms')->onDelete('set null');
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('training_sessions');
    }
};
