import 'package:equatable/equatable.dart';

class AuditEntry extends Equatable {
  final String id;
  final int userId;
  final String userName;
  final String userRole;
  final String action;
  final String entityType;
  final String? entityId;
  final String details;
  final String ipAddress;
  final String? userAgent;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AuditEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.details,
    this.ipAddress = '127.0.0.1',
    this.userAgent,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userRole,
        action,
        entityType,
        entityId,
        details,
        ipAddress,
        userAgent,
        timestamp,
        metadata,
      ];
}
