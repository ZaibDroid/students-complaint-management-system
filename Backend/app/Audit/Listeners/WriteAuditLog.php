<?php

namespace App\Audit\Listeners;

use App\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class WriteAuditLog
{
    /**
     * Handle the event.
     */
    public function handle(object $event): void
    {
        $action = class_basename($event);
        
        $userId = request()->user()?->id;
        $ip = request()->ip();
        $userAgent = request()->userAgent();

        // Attempt to extract the primary model from the event properties.
        // E.g., $event->Application, $event->notice, $event->user
        $model = null;
        
        $reflection = new \ReflectionClass($event);
        foreach ($reflection->getProperties() as $property) {
            $property->setAccessible(true);
            $value = $property->getValue($event);
            if ($value instanceof Model) {
                $model = $value;
                break;
            }
        }

        // For auth events like UserLoggedIn, the model is the User itself.
        if ($model instanceof \App\Models\User && !$userId) {
            $userId = $model->id;
        }

        $oldValues = null;
        $newValues = null;

        $hiddenFields = ['password', 'password_confirmation', 'token', 'access_token', 'refresh_token', 'otp'];

        if ($model) {
            // Only capture specific dirty fields that changed, saving space.
            if ($model->wasChanged()) {
                $newValues = $model->getChanges();
                $oldValues = array_intersect_key($model->getOriginal(), $newValues);
                
                // Mask sensitive fields
                foreach ($hiddenFields as $field) {
                    if (isset($newValues[$field])) {
                        $newValues[$field] = '********';
                    }
                    if (isset($oldValues[$field])) {
                        $oldValues[$field] = '********';
                    }
                }
            }
        }

        AuditLog::create([
            'user_id' => $userId,
            'action' => $action,
            'model_type' => $model ? get_class($model) : null,
            'model_id' => $model ? $model->getKey() : null,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip' => $ip,
            'user_agent' => Str::limit($userAgent, 250),
        ]);
    }
}
