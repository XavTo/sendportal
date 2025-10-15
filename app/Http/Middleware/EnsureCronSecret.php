<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureCronSecret
{
    public function handle(Request $request, Closure $next): Response
    {
        $provided = $request->header('X-Cron-Secret');
        $expected = config('app.cron_secret') ?: env('CRON_SECRET');

        if (!$expected || !hash_equals((string) $expected, (string) $provided)) {
            abort(401, 'Unauthorized');
        }

        return $next($request);
    }
}
