<?php

namespace App\Audit\Controllers;

use App\Audit\Repositories\AuditRepository;
use App\Audit\Resources\AuditResource;
use App\Http\Controllers\Api\V1\BaseApiController;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuditController extends BaseApiController
{
    public function __construct(protected AuditRepository $auditRepository)
    {
        $this->middleware('can:audit.view');
    }

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['action', 'user_id', 'from_date', 'to_date']);
        $perPage = $request->input('per_page', 50);

        $audits = $this->auditRepository->search($filters, $perPage);

        return $this->successResponse(
            AuditResource::collection($audits)->response()->getData(true),
            'Audit logs retrieved successfully.'
        );
    }
}
