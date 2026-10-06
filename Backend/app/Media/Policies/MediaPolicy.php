<?php

namespace App\Media\Policies;

use App\Models\Media;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class MediaPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can download/view the media.
     */
    public function view(User $user, Media $media): bool
    {
        // For public visibility, always allow
        if ($media->visibility === 'public') {
            return true;
        }

        // If the user uploaded it, they can view it
        if ($media->uploaded_by === $user->id) {
            return true;
        }

        // Admins can view all media
        if ($user->hasRole('Admin')) {
            return true;
        }

        // Otherwise, defer to the parent model's policy
        // If they can view the Application/Notice, they can view its attachments
        $parentModel = $media->model;
        if ($parentModel) {
            return $user->can('view', $parentModel);
        }

        return false;
    }
}
