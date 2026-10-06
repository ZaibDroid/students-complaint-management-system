<?php

namespace App\Enums;

enum NoticeStatus: string
{
    case Draft = 'draft';
    case Published = 'published';
    case Scheduled = 'scheduled';
    case Expired = 'expired';
}
