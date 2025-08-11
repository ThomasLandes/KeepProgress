<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;
use App\Models\User;
use App\Models\Exercise;

Route::middleware(['throttle:60,1'])->group(function () {
    Route::post('/login', function (Request $request) {
        $data = $request->validate([
            'email' => ['required','email'],
            'password' => ['required','string'],
        ]);

        /** @var User|null $user */
        $user = User::where('user_email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->user_password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('android', ['*'])->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->user_id,
                'name' => $user->user_name,
                'email' => $user->user_email,
            ],
        ]);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', function (Request $request) {
        $u = $request->user();
        return response()->json([
            'id' => $u->user_id,
            'name' => $u->user_name,
            'email' => $u->user_email,
            'isAdmin' => (bool) $u->isAdmin,
        ]);
    });

    Route::get('/exercises', function () {
        return Exercise::query()
            ->select('exercise_id','exercise_name','exercise_description','updated_at')
            ->orderBy('exercise_name')
            ->get();
    });

    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    });

    Route::post('/logout-all', function (Request $request) {
        $request->user()->tokens()->delete();
        return response()->json(['message' => 'Logged out from all devices']);
    });
});
