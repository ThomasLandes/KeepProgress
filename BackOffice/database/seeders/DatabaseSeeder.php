<?php

namespace Database\Seeders;

use App\Models\Exercise;
use App\Models\User;
use App\Models\SessionContent;
use App\Models\TrainingSession;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            // 1) Assure au moins quelques exercices (si la table est vide)
            if (Exercise::count() < 5) {
                $defaults = [
                    ['exercise_name' => 'Bench Press', 'exercise_description' => 'Développé couché'],
                    ['exercise_name' => 'Back Squat', 'exercise_description' => 'Squat barre'],
                    ['exercise_name' => 'Deadlift', 'exercise_description' => 'Soulevé de terre'],
                    ['exercise_name' => 'Overhead Press', 'exercise_description' => 'Développé militaire'],
                    ['exercise_name' => 'Pull Ups', 'exercise_description' => 'Tractions'],
                ];
                foreach ($defaults as $d) {
                    Exercise::firstOrCreate(
                        ['exercise_name' => $d['exercise_name']],
                        ['exercise_description' => $d['exercise_description'] ?? null]
                    );
                }
            }

            $exerciseIds = Exercise::query()->pluck('exercise_id')->all();
            if (empty($exerciseIds)) {
                $this->command?->warn('Aucun exercice disponible. Abandon du seeding des sessions.');
                return;
            }

            // 2) Crée des sessions pour les users 1, 2, 3
            $userIds = User::query()->limit(3)->pluck('user_id')->all();

            foreach ($userIds as $uid) {
                // 3 séances par user
                for ($i = 0; $i < 3; $i++) {
                    $session = TrainingSession::create([
                        'user_id'      => $uid,
                        'session_date' => now()->subDays(rand(0, 10))->setTime(rand(8, 20), [0, 15, 30, 45][rand(0,3)]),
                        'duration'     => rand(45, 90), // minutes
                    ]);

                    // 3 à 5 exercices par séance
                    $count = rand(3, 5);
                    $picked = collect($exerciseIds)->shuffle()->take($count);

                    foreach ($picked as $exId) {
                        SessionContent::create([
                            'training_session_id' => $session->training_session_id,
                            'exercise_id'         => $exId,
                            'sets'                => $sets = rand(3, 5),
                            'reps'                => $reps = [8, 10, 12][rand(0,2)],
                            'weight'              => round(rand(20, 100) + rand(0, 9)*0.5, 1),
                        ]);
                    }
                }
            }
        });
    }
}
