<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\PrivateDocumentController;

Route::get('/', function () {
    return view('welcome');
});

// Routes pour servir les documents privés (admin uniquement)
// Ces routes doivent être APRÈS le middleware web mais AVANT les routes Filament
Route::middleware(['web'])->prefix('admin/documents')->group(function () {
    Route::get('/view/{path}', [PrivateDocumentController::class, 'show'])
        ->where('path', '.*')
        ->name('admin.documents.view');
    Route::get('/download/{path}', [PrivateDocumentController::class, 'download'])
        ->where('path', '.*')
        ->name('admin.documents.download');
});

// Proxy for images to handle CORS in development
Route::get('/img-proxy/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    
    if (!file_exists($filePath)) {
        abort(404);
    }
    
    $file = \Illuminate\Support\Facades\File::get($filePath);
    $type = \Illuminate\Support\Facades\File::mimeType($filePath);
    
    return response($file, 200)->header("Content-Type", $type)
        ->header("Access-Control-Allow-Origin", "*");
})->where('path', '.*');
