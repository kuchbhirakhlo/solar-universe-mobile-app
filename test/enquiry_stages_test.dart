import 'package:flutter_test/flutter_test.dart';
import 'package:solaruniverse/features/staff_enquiries/data/models/staff_enquiry_model.dart';
import 'package:solaruniverse/features/staff_enquiries/domain/enquiry_stages.dart';

void main() {
  group('EnquiryStages', () {
    test('normalises legacy ALL-CAPS and mixed-case to the CRM title-case strings', () {
      expect(EnquiryStages.normalize('INTERESTED'), 'Interested');
      expect(EnquiryStages.normalize('file submitted in bank'), 'File Submitted in Bank');
      expect(EnquiryStages.normalize('Paper Received'), 'Paper Received');
      expect(EnquiryStages.normalize('CONVERTED'), 'Converted');
    });

    test('leaves unknown/legacy stages unchanged', () {
      expect(EnquiryStages.normalize('New'), 'New');
    });

    test('staff cannot select Converted (admin-only in the CRM) but all 9 others are offered', () {
      expect(EnquiryStages.staffSelectable, isNot(contains('Converted')));
      expect(EnquiryStages.staffSelectable.length, 9);
      expect(EnquiryStages.all.length, 10);
      expect(EnquiryStages.isConverted('CONVERTED'), isTrue);
      expect(EnquiryStages.isConverted('Interested'), isFalse);
    });
  });

  group('StaffEnquiryModel.fromMap', () {
    final base = {
      'name': 'A',
      'phone': '9876543210',
      'city': 'Lucknow',
      'solarType': 'On Grid',
      'capacity': '3KW',
      'message': 'm',
      'status': 'INTERESTED',
      'createdAt': '2026-10-06T08:38:59.172Z',
    };

    test('old documents without remark/statusHistory still parse', () {
      final e = StaffEnquiryModel.fromMap('id1', base);
      expect(e.remark, isNull);
      expect(e.statusHistory, isEmpty);
    });

    test('parses the CRM statusHistory shape (ISO updatedAt)', () {
      final e = StaffEnquiryModel.fromMap('id2', {
        ...base,
        'remark': 'done paper',
        'statusHistory': [
          {
            'status': 'Interested',
            'remark': 'Logged',
            'updatedBy': 'Aviral Shukla',
            'updatedAt': '2026-10-06T08:38:59.172Z',
          },
          {
            'status': 'Converted',
            'remark': 'done paper',
            'updatedBy': 'Admin',
            'updatedAt': '2026-10-06T09:00:00.000Z',
          },
        ],
      });
      expect(e.remark, 'done paper');
      expect(e.statusHistory.length, 2);
      expect(e.statusHistory.last.status, 'Converted');
      expect(e.statusHistory.first.updatedBy, 'Aviral Shukla');
    });
  });
}
