import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../staff_enquiries/domain/enquiry_stages.dart';
import '../../domain/entities/contact_message_entity.dart';
import '../../domain/entities/enquiry_entity.dart';

abstract class EnquiryDataSource {
  Future<void> submitEnquiry(EnquiryEntity enquiry);
  Future<void> submitContactMessage(ContactMessageEntity message);
}

/// Both the quote form and the "Send Message" contact form write into the
/// admin's single `enquiries` collection (its CRM pipeline: Interested ->
/// Contacted -> Site Visit -> ...) — there is no separate collection for
/// general contact messages, so it's tagged via `source` instead.
///
/// Documents must look exactly like the website's own `addEnquiry` output
/// (status 'Interested', a `remark`, and a `statusHistory` creation entry) or
/// the admin panel shows them with the wrong stage and an empty history. The
/// app used to write status 'New', which isn't a CRM stage.
class EnquiryDataSourceImpl implements EnquiryDataSource {
  final FirebaseFirestore firestore;

  EnquiryDataSourceImpl(this.firestore);

  static const String _updatedBy = 'Mobile App';

  Map<String, dynamic> _crmFields(String remark, String createdAt) {
    final firstRemark = remark.trim().isEmpty ? 'Enquiry received via mobile app' : remark.trim();
    return {
      'status': EnquiryStages.initial,
      'remark': firstRemark,
      'statusHistory': [
        {
          'status': EnquiryStages.initial,
          'remark': firstRemark,
          'updatedBy': _updatedBy,
          'updatedAt': createdAt,
        },
      ],
      'createdAt': createdAt,
    };
  }

  @override
  Future<void> submitEnquiry(EnquiryEntity enquiry) async {
    final createdAt = DateTime.now().toUtc().toIso8601String();
    await firestore.collection('enquiries').add({
      'name': enquiry.name,
      'phone': enquiry.mobile,
      'city': enquiry.city,
      'solarType': enquiry.systemType,
      'capacity': enquiry.capacity,
      'message': enquiry.composedMessage,
      'source': enquiry.source,
      ..._crmFields(enquiry.composedMessage, createdAt),
    });
  }

  @override
  Future<void> submitContactMessage(ContactMessageEntity message) async {
    final createdAt = DateTime.now().toUtc().toIso8601String();
    await firestore.collection('enquiries').add({
      'name': message.name,
      'phone': message.phone,
      'email': message.email,
      'city': 'N/A',
      'solarType': 'General Enquiry',
      'capacity': 'N/A',
      'message': message.message,
      'source': 'contact_form',
      ..._crmFields(message.message, createdAt),
    });
  }
}
