<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class RegisterStudentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email',
                'regex:/^[a-zA-Z0-9._%+-]+@uetmardan\.edu\.pk$/i',
            ],
            'password' => ['required', 'string', 'min:6'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'department' => ['nullable', 'string', 'max:100'],
            'batch_id' => ['required_without:batch', 'nullable', 'exists:batches,id'],
            'batch' => ['required_without:batch_id', 'nullable', 'string', 'max:50'],
            'section_id' => ['required_without:section', 'nullable', 'exists:sections,id'],
            'section' => ['required_without:section_id', 'nullable', 'string', 'max:20'],
            'year' => ['nullable', 'string'],
            'semester' => ['nullable', 'string'],
            'current_semester' => ['nullable', 'integer', 'min:1', 'max:8'],
            'registration_number' => ['nullable', 'string', 'max:50'],
            'adviser_id' => ['nullable', 'exists:users,id'],
            'adviser' => ['nullable', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
            'status' => ['nullable', 'string'],
            'is_cr' => ['prohibited'],
            'isCR' => ['prohibited'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $batchId = $this->input('batch_id');
            $batchStr = $this->input('batch');
            $sectionId = $this->input('section_id');
            $sectionStr = $this->input('section');

            $batch = null;
            if ($batchId) {
                $batch = \App\Models\Batch::find($batchId);
            } elseif (!empty($batchStr)) {
                $raw = trim((string)$batchStr);
                $batch = \App\Models\Batch::where('name', $raw)
                    ->orWhere('name', 'Batch ' . $raw)
                    ->first();
            }

            if (!$batch || !$batch->is_active) {
                $validator->errors()->add('batch_id', 'The selected batch is invalid or unavailable.');
            } elseif (!$batch->hasActiveCoordinator()) {
                $validator->errors()->add('batch_id', 'The selected batch is invalid, inactive, or has no assigned Coordinator.');
            }

            $section = null;
            if ($sectionId && $batch) {
                $section = \App\Models\Section::where('id', $sectionId)
                    ->where('batch_id', $batch->id)
                    ->first();
            } elseif (!empty($sectionStr) && $batch) {
                $rawSec = trim((string)$sectionStr);
                $cleanSec = trim(preg_replace('/^(section\s*|sec\s*)/i', '', $rawSec));
                $section = \App\Models\Section::where('batch_id', $batch->id)
                    ->where(function ($q) use ($rawSec, $cleanSec) {
                        $q->where('name', $rawSec)
                          ->orWhere('name', $cleanSec)
                          ->orWhere('name', 'Section ' . $cleanSec);
                    })->first();
            }

            if (!$section || !$section->is_active) {
                $validator->errors()->add('section_id', 'The selected section does not belong to the selected batch or is unavailable.');
            }
        });
    }

    public function messages(): array
    {
        return [
            'email.regex' => 'Registration is restricted to official @uetmardan.edu.pk email addresses.',
            'is_cr.prohibited' => 'Students cannot assign themselves Class Representative status during registration.',
            'isCR.prohibited' => 'Students cannot assign themselves Class Representative status during registration.',
        ];
    }
}
