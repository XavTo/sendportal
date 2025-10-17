<?php

declare(strict_types=1);

use App\Http\Middleware\RequireWorkspace;
use Illuminate\Support\Facades\Route;
use Sendportal\Base\Facades\Sendportal;

// Routes API existantes (SendPortal)
Route::middleware([
    config('sendportal-host.throttle_middleware'),
    RequireWorkspace::class,
])->group(function () {
    Sendportal::apiRoutes();
});
Sendportal::publicApiRoutes();

// --- Déclencheur cron interne protégé --- //
Route::post('/internal/trigger-schedule', function () {
    \Log::info('Schedule trigger called', ['timestamp' => now()]);
    
    $exitCode = \Artisan::call('schedule:run', []);
    
    \Log::info('Schedule run completed', [
        'exit_code' => $exitCode,
        'output' => \Artisan::output()
    ]);
    
    return response()->json([
        'ok' => true,
        'exit_code' => $exitCode,
        'output' => \Artisan::output()
    ]);
})->middleware(['throttle:5,1', 'cron.secret'])->name('internal.trigger-schedule');
