<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Cache\RateLimiter;
use Symfony\Component\HttpFoundation\Response;

class ApiThrottle
{
    protected $limiter;

    public function __construct(RateLimiter $limiter)
    {
        $this->limiter = $limiter;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string $limit = '60'): Response
    {
        $key = $this->resolveRequestSignature($request);
        
        if ($this->limiter->tooManyAttempts($key, $limit)) {
            return response()->json([
                'message' => 'Too many requests. Please try again later.',
                'retry_after' => $this->limiter->availableIn($key),
            ], 429);
        }

        $this->limiter->hit($key, 60);

        $response = $next($request);

        return $this->addHeaders(
            $response,
            $limit,
            $this->calculateRemainingAttempts($key, $limit)
        );
    }

    /**
     * Resolve the request signature.
     */
    protected function resolveRequestSignature(Request $request): string
    {
        if ($user = $request->user()) {
            return sha1('api_throttle|' . $user->id);
        }

        return sha1('api_throttle|' . $request->ip());
    }

    /**
     * Calculate the remaining attempts.
     */
    protected function calculateRemainingAttempts(string $key, int $limit): int
    {
        return $this->limiter->remaining($key, $limit);
    }

    /**
     * Add rate limit headers to response.
     */
    protected function addHeaders(Response $response, int $limit, int $remaining): Response
    {
        $response->headers->add([
            'X-RateLimit-Limit' => $limit,
            'X-RateLimit-Remaining' => max(0, $remaining),
        ]);

        return $response;
    }
}
