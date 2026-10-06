<?php

namespace App\Http\Controllers\Api;

use App\Concerns\ApiResponse;
use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

abstract class BaseApiController extends Controller
{
    use ApiResponse, AuthorizesRequests;
}
