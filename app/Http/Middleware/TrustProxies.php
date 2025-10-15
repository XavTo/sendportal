<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * Faire confiance aux proxys en amont (Railway).
     * Vous pouvez restreindre à une liste d’IP si besoin.
     *
     * @var array|string|null
     */
    protected $proxies = '*';

    /**
     * En-têtes à honorer pour détecter schéma/hôte/port/IP réels.
     *
     * @var int
     */
    protected $headers =
        Request::HEADER_X_FORWARDED_FOR |
        Request::HEADER_X_FORWARDED_HOST |
        Request::HEADER_X_FORWARDED_PORT |
        Request::HEADER_X_FORWARDED_PROTO |
        Request::HEADER_X_FORWARDED_AWS_ELB;
}
