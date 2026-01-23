<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
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
