<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class SubmitApplicationRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        if (!$this->has('category_id') && $this->has('category')) {
            $cat = strtolower((string) $this->input('category'));
            $categoryId = null;
            if (str_contains($cat, 'acad')) {
                $categoryId = \App\Models\ApplicationCategory::where('slug', 'academic')->value('id');
            } elseif (str_contains($cat, 'facil') || str_contains($cat, 'infra') || str_contains($cat, 'it') || str_contains($cat, 'network')) {
                $categoryId = \App\Models\ApplicationCategory::where('slug', 'infrastructure')->value('id');
            } elseif (str_contains($cat, 'admin') || str_contains($cat, 'finan') || str_contains($cat, 'fee')) {
                $categoryId = \App\Models\ApplicationCategory::where('slug', 'administrative')->value('id');
            } else {
                $categoryId = \App\Models\ApplicationCategory::first()?->id;
            }

            if ($categoryId) {
                $this->merge(['category_id' => $categoryId]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'category_id' => ['required', 'exists:application_categories,id'],
            'category' => ['nullable', 'string'],
            'priority' => ['nullable', 'in:low,medium,high,urgent'],
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:5120'],
        ];
    }
}
