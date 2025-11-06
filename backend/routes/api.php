<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:api');
    Route::post('refresh', [AuthController::class, 'refresh'])->middleware('auth:api');
    Route::get('me', [AuthController::class, 'me'])->middleware('auth:api');
});

Route::middleware('auth:api')->group(function () {
    Route::get('events/day/{date}', [EventController::class, 'getEventsByDay']);
    Route::apiResource('events', EventController::class);
});

/*
|--------------------------------------------------------------------------
| API Routes - Health Check
|--------------------------------------------------------------------------
*/

// Route de santé pour Kubernetes
Route::get('/health', function () {
    try {
        // Vérifier la connexion à la base de données
        DB::connection()->getPdo();
        
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now()->toIso8601String(),
            'database' => 'connected'
        ], 200);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'unhealthy',
            'timestamp' => now()->toIso8601String(),
            'database' => 'disconnected',
            'error' => $e->getMessage()
        ], 500);
    }
});

// Route de readiness pour Kubernetes
Route::get('/ready', function () {
    try {
        // Vérifications plus complètes
        DB::connection()->getPdo();
        
        // Vérifier que les tables existent (exemple)
        $tables = DB::select('SHOW TABLES');
        
        return response()->json([
            'status' => 'ready',
            'timestamp' => now()->toIso8601String(),
            'database' => 'connected',
            'tables_count' => count($tables)
        ], 200);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'not_ready',
            'timestamp' => now()->toIso8601String(),
            'error' => $e->getMessage()
        ], 503);
    }
});

// Vos autres routes API...