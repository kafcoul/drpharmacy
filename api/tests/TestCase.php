<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        if (config('database.default') === 'sqlite' || config('database.connections.sqlite.driver') === 'sqlite') {
            try {
                $db = $this->app['db']->connection()->getPdo();
                $db->sqliteCreateFunction('acos', 'acos', 1);
                $db->sqliteCreateFunction('cos', 'cos', 1);
                $db->sqliteCreateFunction('radians', 'deg2rad', 1);
                $db->sqliteCreateFunction('sin', 'sin', 1);
            } catch (\Exception $e) {
                // Functions might already be registered
            }
        }
    }
}
