import 'package:equatable/equatable.dart';

class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) fromJsonT,
  ) {
    final rawData = json['data'] as List? ?? [];
    final items = rawData.map(fromJsonT).toList();

    return PaginatedResponse<T>(
      data: items,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? items.length,
      perPage: json['per_page'] as int? ?? items.length,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, lastPage, total, perPage];
}
