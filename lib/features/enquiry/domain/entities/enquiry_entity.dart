import 'package:equatable/equatable.dart';

class EnquiryEntity extends Equatable {
  final String name;
  final String mobile;
  final String city;
  final String systemType;
  final String capacity;
  final String message;
  final String source;

  /// Extra lead details captured by the homepage forms/calculators. They have
  /// no dedicated Firestore fields (matching the website's `addEnquiry`), so
  /// the datasource folds them into `message` for CRM compatibility.
  final String? whatsapp;
  final String? state;
  final String? monthlyBill;
  final String? context;

  const EnquiryEntity({
    required this.name,
    required this.mobile,
    required this.city,
    required this.systemType,
    required this.capacity,
    required this.message,
    required this.source,
    this.whatsapp,
    this.state,
    this.monthlyBill,
    this.context,
  });

  bool get hasExtendedDetails =>
      whatsapp != null || state != null || monthlyBill != null || context != null;

  /// Same layout the website writes:
  /// "{context}\nWhatsApp: ..\nState: ..\nMonthly bill: ..\n{message}".
  String get composedMessage {
    if (!hasExtendedDetails) return message;
    final wa = (whatsapp == null || whatsapp!.trim().isEmpty) ? mobile : whatsapp!.trim();
    final st = (state == null || state!.trim().isEmpty) ? 'To be confirmed' : state!.trim();
    final bill =
        (monthlyBill == null || monthlyBill!.trim().isEmpty) ? 'Not provided' : monthlyBill!.trim();
    return [
      if (context != null && context!.trim().isNotEmpty) context!.trim(),
      'WhatsApp: $wa',
      'State: $st',
      'Monthly bill: $bill',
      if (message.trim().isNotEmpty) message.trim(),
    ].join('\n');
  }

  @override
  List<Object?> get props => [
        name,
        mobile,
        city,
        systemType,
        capacity,
        message,
        source,
        whatsapp,
        state,
        monthlyBill,
        context,
      ];
}
