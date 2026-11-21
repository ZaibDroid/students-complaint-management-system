<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;
use Illuminate\Validation\Rule;

class UpdateStaffRequest extends BaseApiRequest
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
        $userId = $this->route('user') ? $this->route('user')->id : null;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'string', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId)->whereNull('deleted_at')],
            'password' => ['nullable', 'string', 'min:6'],
            'role' => ['sometimes', 'string', 'exists:roles,name'],
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

            if ($this->has('role')) {
                $requestedRole = (string)$this->input('role');
                if ($user->hasRole('Coordinator')) {
                    $allowed = ['Batch Adviser', 'Batch Advisor', 'Office Staff'];
                    if (!in_array($requestedRole, $allowed, true)) {
                        $validator->errors()->add('role', 'Coordinators can only assign Batch Adviser or Office Staff roles.');
                    }
                } elseif ($user->hasRole('Chairman')) {
                    $allowed = ['Coordinator', 'Batch Adviser', 'Batch Advisor', 'Office Staff'];
                    if (!in_array($requestedRole, $allowed, true)) {
                        $validator->errors()->add('role', 'Chairmen cannot assign Admin or Chairman roles.');
                    }
                }
            }

            if ($this->has('department_id')) {
                $requestedDept = (int)$this->input('department_id');
                if (($user->hasRole('Coordinator') || $user->hasRole('Chairman')) && $requestedDept !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'You cannot reassign staff members outside your department.');
                }
            }

            if ($user->hasRole('Coordinator')) {
                $coordinatorBatchIds = $user->getAssignedBatchIds();

                if ($this->has('batch_id') && !empty($this->input('batch_id'))) {
                    $batchId = (int)$this->input('batch_id');
                    if (!in_array($batchId, $coordinatorBatchIds, true)) {
                        $validator->errors()->add('batch_id', 'You are not authorized to assign staff to batches outside your coordination.');
                    }
                }

                if ($this->has('section_id') && !empty($this->input('section_id'))) {
                    $section = \App\Models\Section::find((int)$this->input('section_id'));
                    if (!$section || !in_array((int)$section->batch_id, $coordinatorBatchIds, true)) {
                        $validator->errors()->add('section_id', 'You are not authorized to assign staff to sections outside your coordination.');
                    }
                }

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
            }

            $targetUser = $this->route('user');
            $requestedRole = (string)$this->input('role', $targetUser?->roles->first()?->name ?? '');

            if ($targetUser && $targetUser->hasRole('Chairman') && $this->has('department_id')) {
                $newDeptId = (int)$this->input('department_id');
                if ($targetUser->department_id && (int)$targetUser->department_id !== $newDeptId) {
                    $hasActiveRecords = \App\Models\Application::where('assigned_to_id', $targetUser->id)
                        ->whereNotIn('status', ['resolved', 'rejected'])
                        ->exists();
                    if ($hasActiveRecords) {
                        $validator->errors()->add('department_id', 'Cannot change department for a Chairman with active assigned complaints. Resolve or reassign complaints first.');
                    }
                }
            }

            if ($requestedRole === 'Coordinator') {
                if ($this->has('batch_id') || $this->has('batch')) {
                    $batchId = $this->input('batch_id');
                    $batchStr = $this->input('batch');

                    $batch = null;
                    if ($batchId) {
                        $batch = \App\Models\Batch::find($batchId);
                    } elseif (!empty($batchStr)) {
                        $raw = trim((string)$batchStr);
                        $batch = \App\Models\Batch::where('name', $raw)
                            ->orWhere('name', 'Batch ' . $raw)
                            ->first();
                    }

                    if ($batch && $batch->coordinator_id !== null && $targetUser && (int)$batch->coordinator_id !== (int)$targetUser->id) {
                        $validator->errors()->add('batch_id', 'This batch is already assigned to another coordinator.');
                    }
                }
            }
        });
    }
}
