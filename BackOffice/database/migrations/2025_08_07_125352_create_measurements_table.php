<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// database/migrations/2024_08_07_100040_create_measurements_table.php
return new class extends Migration {
    public function up(): void
    {
        Schema::create('measurements', function (Blueprint $table) {
            $table->bigIncrements('measurement_id');
            $table->unsignedBigInteger('user_id');
            $table->dateTime('measurement_date');
            $table->string('measurement_type'); // Ex: "poids", "tour de taille"
            $table->float('measurement_value');
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->onDelete('cascade');
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('measurements');
    }
};
