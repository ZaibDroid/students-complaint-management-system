<?php

namespace App\Enums;

enum NotificationType: string
{
    case ApplicationSubmitted = 'ApplicationSubmitted';
    case ApplicationAssigned = 'ApplicationAssigned';
    case ApplicationForwarded = 'ApplicationForwarded';
    case ApplicationReturned = 'ApplicationReturned';
    case ApplicationResolved = 'ApplicationResolved';
    case ApplicationRejected = 'ApplicationRejected';
    case ApplicationUpdated = 'ApplicationUpdated';
    case NoticePublished = 'NoticePublished';
    case SystemAnnouncement = 'SystemAnnouncement';
}
