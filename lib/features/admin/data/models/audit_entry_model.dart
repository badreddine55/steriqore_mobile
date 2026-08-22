import '../../domain/entities/audit_entry.dart';

class AuditEntryModel extends AuditEntry {
  const AuditEntryModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.action,
    required super.entityType,
    super.entityId,
    required super.details,
    super.ipAddress = '127.0.0.1',
    super.userAgent,
    required super.timestamp,
    super.metadata,
  });

  factory AuditEntryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return AuditEntryModel(
      id: json['id']?.toString() ?? 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      userName: json['user_name'] as String? ?? json['user']?['name'] as String? ?? 'User',
      userRole: json['user_role'] as String? ?? json['user']?['role'] as String? ?? 'practitioner',
      action: json['action'] as String? ?? 'Action',
      entityType: json['entity_type'] as String? ?? json['target_type'] as String? ?? 'system',
      entityId: json['entity_id']?.toString() ?? json['target_id']?.toString(),
      details: json['details'] as String? ?? json['description'] as String? ?? '',
      ipAddress: json['ip_address'] as String? ?? '192.168.1.45',
      userAgent: json['user_agent'] as String? ?? 'Steriqore Mobile (iOS/Android)',
      timestamp: parseDate(json['timestamp'] ?? json['created_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'details': details,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  AuditEntry toEntity() {
    return AuditEntry(
      id: id,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      ipAddress: ipAddress,
      userAgent: userAgent,
      timestamp: timestamp,
      metadata: metadata,
    );
  }
}
