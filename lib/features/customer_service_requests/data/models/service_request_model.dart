import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_request_entity.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.customerMobile,
    required super.serviceType,
    required super.description,
    required super.remark,
    required super.status,
    required super.assignedEngineerId,
    required super.assignedEngineerName,
    required super.estimatedCost,
    required super.createdAt,
    required super.updatedAt,
    super.installationPhotos,
  });

  factory ServiceRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: id,
      customerId: _string(map['customerId']),
      customerName: _string(map['customerName']),
      customerMobile: _string(map['customerMobile']),
      serviceType: _string(map['serviceType']),
      description: _string(map['description']),
      remark: _string(map['remark']),
      status: _string(map['status'], fallback: 'Open'),
      assignedEngineerId: _string(map['assignedEngineerId']),
      assignedEngineerName: _string(map['assignedEngineerName']),
      estimatedCost: _cost(map['estimatedCost']),
      createdAt: _iso(map['createdAt']),
      updatedAt: _iso(map['updatedAt']),
      installationPhotos: _photos(map['installationPhotos']),
    );
  }

  /// Same as [fromMap] but returns null instead of throwing, so one malformed
  /// document cannot empty the whole assigned/history list.
  static ServiceRequestModel? tryFromMap(String id, Map<String, dynamic> map) {
    try {
      return ServiceRequestModel.fromMap(id, map);
    } catch (_) {
      return null;
    }
  }

  static String _string(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }
    return value.toString();
  }

  static num _cost(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static String _iso(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
    if (value is DateTime) return value.toUtc().toIso8601String();
    return value.toString();
  }

  static List<String> _photos(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
}
