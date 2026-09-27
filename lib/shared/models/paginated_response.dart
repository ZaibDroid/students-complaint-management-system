/// Paginated Response wrapper for lists
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    // Laravel pagination structure: { data: [...], current_page: 1, last_page: 5, total: 50, per_page: 15 }
    final List<dynamic> rawList = json['data'] is List ? json['data'] as List : [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => fromJsonT(item))
        .toList();

    return PaginatedResponse<T>(
      items: items,
      currentPage: json['current_page'] ?? json['meta']?['current_page'] ?? 1,
      lastPage: json['last_page'] ?? json['meta']?['last_page'] ?? 1,
      total: json['total'] ?? json['meta']?['total'] ?? items.length,
      perPage: json['per_page'] ?? json['meta']?['per_page'] ?? items.length,
    );
  }
}
