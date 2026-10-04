<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\TeamController;
use Illuminate\Support\Facades\Route;

Route::get('signup/availability', [AuthController::class, 'availability']);
Route::post('signup', [AuthController::class, 'signup']);

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('me', [AuthController::class, 'me']);
        Route::post('logout', [AuthController::class, 'logout']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('branches', [TeamController::class, 'branches']);
    Route::get('locations', [TeamController::class, 'locations']);
    Route::get('users', [TeamController::class, 'users']);

    Route::get('units', [CatalogController::class, 'units']);
    Route::get('categories', [CatalogController::class, 'categories']);
    Route::get('brands', [CatalogController::class, 'brands']);
    Route::get('products', [CatalogController::class, 'products']);

    Route::get('stock/summary', [StockController::class, 'summary']);
    Route::get('stock/balances', [StockController::class, 'balances']);
    Route::get('stock/events', [StockController::class, 'events']);
    Route::get('stock/events/export.csv', [StockController::class, 'exportCsv']);
    Route::get('stock/events/export.pdf', [StockController::class, 'exportPdf']);
    Route::get('stock/adjustments', [StockController::class, 'adjustments']);
    Route::get('stock/transfers', [StockController::class, 'transfers']);
    Route::get('stock/write-offs', [StockController::class, 'writeOffs']);
    Route::get('stock/location-moves', [StockController::class, 'locationMoves']);

    Route::post('sync/push', [SyncController::class, 'push']);
    Route::get('sync/pull', [SyncController::class, 'pull']);

    Route::middleware('role:owner,manager')->group(function () {
        Route::post('branches', [TeamController::class, 'storeBranch']);
        Route::post('locations', [TeamController::class, 'storeLocation']);
        Route::post('units', [CatalogController::class, 'storeUnit']);
        Route::put('units/{id}', [CatalogController::class, 'updateUnit']);
        Route::delete('units/{id}', [CatalogController::class, 'destroyUnit']);
        Route::post('categories', [CatalogController::class, 'storeCategory']);
        Route::put('categories/{id}', [CatalogController::class, 'updateCategory']);
        Route::delete('categories/{id}', [CatalogController::class, 'destroyCategory']);
        Route::post('brands', [CatalogController::class, 'storeBrand']);
        Route::put('brands/{id}', [CatalogController::class, 'updateBrand']);
        Route::delete('brands/{id}', [CatalogController::class, 'destroyBrand']);
        Route::post('products', [CatalogController::class, 'storeProduct']);
        Route::put('products/{id}', [CatalogController::class, 'updateProduct']);
        Route::delete('products/{id}', [CatalogController::class, 'destroyProduct']);
        Route::post('stock/adjustments', [StockController::class, 'storeAdjustment']);
        Route::post('stock/transfers', [StockController::class, 'storeTransfer']);
        Route::post('stock/write-offs', [StockController::class, 'storeWriteOff']);
        Route::post('stock/location-moves', [StockController::class, 'storeLocationMove']);
    });

    Route::middleware('role:owner')->group(function () {
        Route::post('users', [TeamController::class, 'storeUser']);
    });
});
