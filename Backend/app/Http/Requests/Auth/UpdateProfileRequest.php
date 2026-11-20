<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class UpdateProfileRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20'],
            'year' => ['sometimes', 'nullable', 'string'],
            'semester' => ['sometimes', 'nullable', 'string'],
            'batch' => ['sometimes', 'nullable', 'string'],
            'section' => ['sometimes', 'nullable', 'string'],
            'department' => ['sometimes', 'nullable', 'string'],
            'batch_id' => ['sometimes', 'nullable', 'exists:batches,id'],
            'section_id' => ['sometimes', 'nullable', 'exists:sections,id'],
            'department_id' => ['sometimes', 'nullable', 'exists:departments,id'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $user = $this->user();
            if (!$user) {
                return;
            }

            if ($user->hasRole('Coordinator')) {
                if ($this->has('batch_id') || $this->has('batch')) {
                    $batchId = $this->input('batch_id');
                    $batchStr = $this->input('batch');

                    $coordinatedBatchIds = \App\Models\Batch::where('coordinator_id', $user->id)->pluck('id')->all();

                    if ($batchId && !in_array((int)$batchId, $coordinatedBatchIds, true)) {
                        $validator->errors()->add('batch_id', 'Coordinators cannot modify their assigned batch through self-service profile updates.');
                    } elseif (!empty($batchStr)) {
                        $batch = \App\Models\Batch::where('name', $batchStr)->orWhere('name', 'Batch ' . $batchStr)->first();
                        if (!$batch || !in_array((int)$batch->id, $coordinatedBatchIds, true)) {
                            $validator->errors()->add('batch', 'Coordinators cannot modify their assigned batch through self-service profile updates.');
                        }
                    }
                }
            }
        });
    }
}
