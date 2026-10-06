<?php

namespace App\Media\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UploadMediaRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // We check general auth in middleware, specific policies later if needed
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'file' => [
                'required',
                'file',
                'max:10240', // 10MB max
                'mimes:jpg,jpeg,png,pdf,doc,docx,xls,xlsx'
            ],
            'model_type' => ['required', 'string'],
            'model_id' => ['required', 'integer'],
        ];
    }
}
