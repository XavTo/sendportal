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
    \Artisan::call('schedule:run', []);
    return response()->json(['ok' => true]);
})->middleware(['throttle:5,1', 'cron.secret'])->name('internal.trigger-schedule');
