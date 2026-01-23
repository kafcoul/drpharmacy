<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Route;

class GenerateApiDocs extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'drpharma:api-docs {--format=table : Output format (table|json|markdown)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate API documentation from routes';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $routes = $this->getApiRoutes();
        $format = $this->option('format');

        match ($format) {
            'json' => $this->outputJson($routes),
            'markdown' => $this->outputMarkdown($routes),
            default => $this->outputTable($routes),
        };

        return self::SUCCESS;
    }

    /**
     * Get all API routes
     */
    protected function getApiRoutes(): array
    {
        $routes = [];
        
        foreach (Route::getRoutes() as $route) {
            if (str_starts_with($route->uri(), 'api/')) {
                $routes[] = [
                    'method' => implode('|', $route->methods()),
                    'uri' => $route->uri(),
                    'name' => $route->getName() ?? '-',
                    'action' => $route->getActionName(),
                    'middleware' => implode(', ', $route->middleware()),
                ];
            }
        }

        return $routes;
    }

    /**
     * Output as table
     */
    protected function outputTable(array $routes): void
    {
        $this->info('DR-PHARMA API Endpoints');
        $this->newLine();
        
        $this->table(
            ['Method', 'URI', 'Name', 'Middleware'],
            array_map(fn($route) => [
                $route['method'],
                $route['uri'],
                $route['name'],
                $route['middleware'],
            ], $routes)
        );

        $this->newLine();
        $this->info('Total endpoints: ' . count($routes));
    }

    /**
     * Output as JSON
     */
    protected function outputJson(array $routes): void
    {
        $this->line(json_encode($routes, JSON_PRETTY_PRINT));
    }

    /**
     * Output as Markdown
     */
    protected function outputMarkdown(array $routes): void
    {
        $this->line('# DR-PHARMA API Endpoints');
        $this->line('');
        $this->line('Total: ' . count($routes) . ' endpoints');
        $this->line('');
        $this->line('| Method | Endpoint | Name | Middleware |');
        $this->line('|--------|----------|------|------------|');

        foreach ($routes as $route) {
            $this->line(sprintf(
                '| %s | `%s` | %s | %s |',
                $route['method'],
                $route['uri'],
                $route['name'],
                $route['middleware']
            ));
        }
    }
}
