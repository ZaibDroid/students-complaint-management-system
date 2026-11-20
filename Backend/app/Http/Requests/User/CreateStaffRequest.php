<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;
use Illuminate\Validation\Rule;

class CreateStaffRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        $user = $this->user();
        if (!$user) {
            return false;
        }

        return $user->hasAnyRole(['Admin', 'Super Admin', 'Chairman', 'Coordinator']);
    }

    protected function prepareForValidation(): void
    {
        $user = $this->user();
        if ($user && ($user->hasRole('Coordinator') || $user->hasRole('Chairman'))) {
            if (!$this->has('department_id') && $user->department_id) {
                $this->merge(['department_id' => $user->department_id]);
            }
        }

        if (!$this->has('department_id') && $this->has('department') && !empty($this->input('department'))) {
            $deptStr = trim((string)$this->input('department'));
            $cleanName = trim(preg_replace('/^(department\s*of\s*|dept\s*of\s*)/i', '', $deptStr));
            $dept = \App\Models\Department::where('name', $deptStr)
                ->orWhere('name', 'LIKE', "%{$cleanName}%")
                ->first();
            if ($dept) {
                $this->merge(['department_id' => $dept->id]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', Rule::unique('users', 'email')->whereNull('deleted_at')],
            'password' => ['required', 'string', 'min:6'],
            'role' => ['required', 'string', 'exists:roles,name'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'department' => ['nullable', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
            'batch' => ['nullable', 'string'],
            'batch_id' => ['nullable'],
            'section' => ['nullable', 'string'],
            'section_id' => ['nullable'],
            'semester' => ['nullable', 'string'],
            'assigned_sections' => ['nullable', 'array'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $user = $this->user();
            if (!$user) {
                return;
            }

            $requestedRole = (string)$this->input('role');

            if ($user->hasRole('Coordinator')) {
                $allowed = ['Batch Adviser', 'Batch Advisor', 'Office Staff'];
                if (!in_array($requestedRole, $allowed, true)) {
                    $validator->errors()->add('role', 'Coordinators can only create Batch Adviser or Office Staff accounts.');
                }
                if ($this->has('department_id') && (int)$this->input('department_id') !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'Coordinators can only create staff within their own department.');
                }

                $coordinatorBatchIds = $user->getAssignedBatchIds();

                // 1. Validate batch_id if provided
                if ($this->has('batch_id') && !empty($this->input('batch_id'))) {
                    $batchId = (int)$this->input('batch_id');
                    if (!in_array($batchId, $coordinatorBatchIds, true)) {
                        $validator->errors()->add('batch_id', 'You are not authorized to create or assign advisers to this batch.');
                    }
                }

                // 2. Validate batch string if provided
                if ($this->has('batch') && !empty($this->input('batch'))) {
                    $raw = trim((string)$this->input('batch'));
                    $batch = \App\Models\Batch::where('name', $raw)
                        ->orWhere('name', 'Batch ' . $raw)
                        ->first();
                    if ($batch && !in_array((int)$batch->id, $coordinatorBatchIds, true)) {
                        $validator->errors()->add('batch', 'You are not authorized to create or assign advisers to this batch.');
                    }
                }

                // 3. Validate section_id if provided
                if ($this->has('section_id') && !empty($this->input('section_id'))) {
                    $section = \App\Models\Section::find((int)$this->input('section_id'));
                    if (!$section || !in_array((int)$section->batch_id, $coordinatorBatchIds, true)) {
                        $validator->errors()->add('section_id', 'You are not authorized to create or assign advisers to this section.');
                    }
                }

                // 4. Validate assigned_sections if provided
                if ($this->has('assigned_sections') && is_array($this->input('assigned_sections'))) {
                    foreach ($this->input('assigned_sections') as $secItem) {
                        if (is_numeric($secItem)) {
                            $sec = \App\Models\Section::find((int)$secItem);
                            if (!$sec || !in_array((int)$sec->batch_id, $coordinatorBatchIds, true)) {
                                $validator->errors()->add('assigned_sections', 'One or more assigned sections do not belong to your coordinated batch.');
                                break;
                            }
                        } elseif (is_array($secItem)) {
                            if (!empty($secItem['section_id'])) {
                                $sec = \App\Models\Section::find((int)$secItem['section_id']);
                                if (!$sec || !in_array((int)$sec->batch_id, $coordinatorBatchIds, true)) {
                                    $validator->errors()->add('assigned_sections', 'One or more assigned sections do not belong to your coordinated batch.');
                                    break;
                                }
                            }
                            if (!empty($secItem['batch_id']) && !in_array((int)$secItem['batch_id'], $coordinatorBatchIds, true)) {
                                $validator->errors()->add('assigned_sections', 'One or more assigned sections do not belong to your coordinated batch.');
                                break;
                            }
                        }
                    }
                }
            } elseif ($user->hasRole('Chairman')) {
                $allowed = ['Coordinator', 'Batch Adviser', 'Batch Advisor', 'Office Staff'];
                if (!in_array($requestedRole, $allowed, true)) {
                    $validator->errors()->add('role', 'Chairmen can only create Coordinator, Batch Adviser, or Office Staff accounts.');
                }
                if ($this->has('department_id') && (int)$this->input('department_id') !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'Chairmen can only create staff within their own department.');
                }
            } elseif (!$user->hasRole('Admin')) {
                $validator->errors()->add('role', 'You are not authorized to create staff accounts.');
            }

            if ($requestedRole === 'Coordinator') {
                $batchId = $this->input('batch_id');
                $batchStr = $this->input('batch');

                $batch = null;
                if ($batchId) {
                    $batch = \App\Models\Batch::find($batchId);
                } elseif (!empty($batchStr)) {
                    $raw = trim((string)$batchStr);
                    $startYear = null;
                    $endYear = null;
                    if (preg_match('#(20\d{2})\s*[-–—/]\s*(20\d{2})#', $raw, $m)) {
                        $startYear = (int)$m[1];
                        $endYear = (int)$m[2];
                    }
                    $batch = \App\Models\Batch::where('name', $raw)
                        ->orWhere('name', 'Batch ' . $raw)
                        ->when($startYear && $endYear, function ($q) use ($startYear, $endYear) {
                            $q->orWhere(function ($sub) use ($startYear, $endYear) {
                                $sub->where('start_year', $startYear)->where('end_year', $endYear);
                            });
                        })
                        ->first();
                }

                if ($batch && $batch->coordinator_id !== null) {
                    $validator->errors()->add('batch_id', 'This batch is already assigned to another coordinator.');
                }
            }
        });
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'An account with this email address already exists in the system.',
            'password.min' => 'The temporary password must be at least 6 characters.',
        ];
    }
}
