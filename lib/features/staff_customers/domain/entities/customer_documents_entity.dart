import 'package:equatable/equatable.dart';

/// Uploaded document URLs for a solar customer's KYC file. All fields are
/// mandatory at registration time per the Customer Document Collection spec
/// (PAN, Aadhaar front+back, electricity bill, bank proof, rooftop
/// feasibility photos, property documents) — nullable/empty here only
/// because older customer records predate this requirement.
class CustomerDocumentsEntity extends Equatable {
  final String? pan;
  final String? aadhaarFront;
  final String? aadhaarBack;
  final String? electricityBill;
  final String? bankProof;
  final List<String> rooftopPhotos;
  final List<String> propertyDocuments;

  const CustomerDocumentsEntity({
    this.pan,
    this.aadhaarFront,
    this.aadhaarBack,
    this.electricityBill,
    this.bankProof,
    this.rooftopPhotos = const [],
    this.propertyDocuments = const [],
  });

  static const empty = CustomerDocumentsEntity();

  bool get isComplete =>
      pan != null &&
      aadhaarFront != null &&
      aadhaarBack != null &&
      electricityBill != null &&
      bankProof != null &&
      rooftopPhotos.isNotEmpty &&
      propertyDocuments.isNotEmpty;

  Map<String, dynamic> toMap() => {
        if (pan != null) 'pan': pan,
        if (aadhaarFront != null) 'aadhaarFront': aadhaarFront,
        if (aadhaarBack != null) 'aadhaarBack': aadhaarBack,
        if (electricityBill != null) 'electricityBill': electricityBill,
        if (bankProof != null) 'bankProof': bankProof,
        'rooftopPhotos': rooftopPhotos,
        'propertyDocuments': propertyDocuments,
      };

  factory CustomerDocumentsEntity.fromMap(Map<String, dynamic> map) {
    return CustomerDocumentsEntity(
      pan: map['pan'] as String?,
      // 'aadhar' is the older single-file key used before front/back was
      // split out — best-effort mapped onto aadhaarFront for old records.
      aadhaarFront: map['aadhaarFront'] as String? ?? map['aadhar'] as String?,
      aadhaarBack: map['aadhaarBack'] as String?,
      electricityBill: map['electricityBill'] as String?,
      bankProof: map['bankProof'] as String?,
      rooftopPhotos: List<String>.from(map['rooftopPhotos'] as List? ?? const []),
      propertyDocuments: List<String>.from(map['propertyDocuments'] as List? ?? const []),
    );
  }

  CustomerDocumentsEntity copyWith({
    String? pan,
    String? aadhaarFront,
    String? aadhaarBack,
    String? electricityBill,
    String? bankProof,
    List<String>? rooftopPhotos,
    List<String>? propertyDocuments,
  }) {
    return CustomerDocumentsEntity(
      pan: pan ?? this.pan,
      aadhaarFront: aadhaarFront ?? this.aadhaarFront,
      aadhaarBack: aadhaarBack ?? this.aadhaarBack,
      electricityBill: electricityBill ?? this.electricityBill,
      bankProof: bankProof ?? this.bankProof,
      rooftopPhotos: rooftopPhotos ?? this.rooftopPhotos,
      propertyDocuments: propertyDocuments ?? this.propertyDocuments,
    );
  }

  @override
  List<Object?> get props => [
        pan,
        aadhaarFront,
        aadhaarBack,
        electricityBill,
        bankProof,
        rooftopPhotos,
        propertyDocuments,
      ];
}
