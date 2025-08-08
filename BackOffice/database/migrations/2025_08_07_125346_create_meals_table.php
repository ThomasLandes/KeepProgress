<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// database/migrations/2024_08_07_100050_create_meals_table.php
return new class extends Migration {
    public function up(): void
    {
        Schema::create('meals', function (Blueprint $table) {
            $table->bigIncrements('meal_id');
            $table->unsignedBigInteger('user_id');
            $table->dateTime('meal_date');
            $table->string('meal_type'); // Ex: "petit-déjeuner", "déjeuner"
            $table->string('meal_description')->nullable();
            $table->integer('calories')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->onDelete('cascade');
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('meals');
    }
};

