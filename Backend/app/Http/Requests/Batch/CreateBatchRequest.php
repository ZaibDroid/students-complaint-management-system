<?php

namespace App\Http\Requests\Batch;

use App\Http\Requests\BaseApiRequest;

class CreateBatchRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        $input = $this->all();

        $rawName = trim((string)($input['name'] ?? $input['batch_year'] ?? $input['year'] ?? ''));
        $startYear = $input['start_year'] ?? null;

        if (!$startYear) {
            if (is_numeric($rawName)) {
                $num = (int)$rawName;
                if ($num >= 2000) {
                    $startYear = $num;
                } else if ($num >= 1 && $num <= 50) {
                    $startYear = 2017 + $num; // Batch 1 = 2018, Batch 6 = 2023
                }
            } else if (preg_match('/\b(20\d{2})\b/', $rawName, $matches)) {
                $startYear = (int)$matches[1];
            } else if (preg_match('/Batch\s*(\d+)/i', $rawName, $matches)) {
                $num = (int)$matches[1];
                $startYear = $num >= 2000 ? $num : (2017 + $num);
            }
        }

        if (!$startYear || $startYear < 2018) {
            $startYear = (int)date('Y');
        }

        $endYear = $input['end_year'] ?? ($startYear + 4);
        $canonicalName = (string)$startYear; // e.g. "2023"

        $this->merge([
            'start_year' => (int)$startYear,
            'end_year' => (int)$endYear,
            'name' => $canonicalName,
        ]);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'start_year' => ['nullable', 'integer'],
            'end_year' => ['nullable', 'integer'],
            'is_active' => ['nullable', 'boolean'],
            'sections' => ['nullable', 'array'],
        ];
    }
}
