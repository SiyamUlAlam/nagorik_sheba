class ServiceReport {
  final String id;
  final String? serviceId;
  final String serviceName;
  final String issueType;
  final String issueDescription;
  final String? reporterName;
  final String? reporterPhone;
  final String status;
  final DateTime? createdAt;

  const ServiceReport({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.issueType,
    required this.issueDescription,
    required this.reporterName,
    required this.reporterPhone,
    required this.status,
    required this.createdAt,
  });

  factory ServiceReport.fromMap(Map<String, dynamic> map) {
    return ServiceReport(
      id: map['id']?.toString() ?? '',
      serviceId: map['service_id']?.toString(),
      serviceName: map['service_name']?.toString() ?? '',
      issueType: map['issue_type']?.toString() ?? '',
      issueDescription: map['issue_description']?.toString() ?? '',
      reporterName: map['reporter_name']?.toString(),
      reporterPhone: map['reporter_phone']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}