/// Target audience for notice board announcements
enum NoticeTarget {
  all,
  year,
  batch,
  section;

  String get displayName {
    switch (this) {
      case NoticeTarget.all:
        return 'All Students & Staff';
      case NoticeTarget.year:
        return 'Specific Year';
      case NoticeTarget.batch:
        return 'Specific Batch';
      case NoticeTarget.section:
        return 'Specific Section';
    }
  }

  String get value => name;

  static NoticeTarget fromString(String? target) {
    if (target == null) return NoticeTarget.all;
    switch (target.toLowerCase()) {
      case 'year':
        return NoticeTarget.year;
      case 'batch':
        return NoticeTarget.batch;
      case 'section':
        return NoticeTarget.section;
      case 'all':
      default:
        return NoticeTarget.all;
    }
  }
}
