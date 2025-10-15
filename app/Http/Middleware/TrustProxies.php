<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * Proxys de confiance (ici : tous les proxys en amont).
     * Vous pouvez restreindre à une liste d’IP si besoin.
     *
     * @var array|string|null
     */
    protected $proxies = '*';

    /**
     * En-têtes à honorer pour détecter le schéma/hôte/port/IP réels.
     *
     * @var int
     */
    protected $headers = Request::HEADER_X_FORWARDED_ALL;
}
