class UsageRequestModel {
  final String patientId;
  final String practitionerId;
  final String usedAt;
  final String idempotencyKey;
  final String? procedureType;
  final String? notes;

  const UsageRequestModel({
    required this.patientId,
    required this.practitionerId,
    required this.usedAt,
    required this.idempotencyKey,
    this.procedureType,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'practitioner_id': practitionerId,
      'used_at': usedAt,
      'idempotency_key': idempotencyKey,
      if (procedureType != null) 'procedure_type': procedureType,
      if (notes != null) 'notes': notes,
    };
  }
}
