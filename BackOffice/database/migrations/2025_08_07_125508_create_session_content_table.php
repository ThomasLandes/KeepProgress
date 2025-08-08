<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// database/migrations/2024_08_07_100060_create_session_content_table.php
return new class extends Migration {
    public function up(): void
    {
        Schema::create('session_content', function (Blueprint $table) {
            $table->bigIncrements('session_content_id');
            $table->unsignedBigInteger('training_session_id');
            $table->unsignedBigInteger('exercise_id');
            $table->integer('reps')->nullable();
            $table->integer('sets')->nullable();
            $table->float('weight')->nullable();
            $table->timestamps();

            $table->foreign('training_session_id')->references('training_session_id')->on('training_sessions')->onDelete('cascade');
            $table->foreign('exercise_id')->references('exercise_id')->on('exercises')->onDelete('cascade');
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('session_content');
    }
};
