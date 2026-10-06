<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'name' => config('app.name'),
        'status' => 'Active',
        'api_docs' => '/api/v1/health'
    ]);
});
