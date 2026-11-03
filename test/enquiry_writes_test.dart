import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solaruniverse/features/enquiry/data/datasources/enquiry_datasource.dart';
import 'package:solaruniverse/features/enquiry/domain/entities/contact_message_entity.dart';
import 'package:solaruniverse/features/enquiry/domain/entities/enquiry_entity.dart';
import 'package:solaruniverse/features/staff_enquiries/data/datasources/staff_enquiries_datasource.dart';

/// Runs the REAL datasource code against an in-memory Firestore and checks the
/// stored documents have exactly the shape the website CRM writes/reads
/// (`addEnquiry` / `updateEnquiryStatus` in the website's db.ts).
void main() {
  late FakeFirebaseFirestore fs;

  setUp(() => fs = FakeFirebaseFirestore());

  Future<Map<String, dynamic>> onlyEnquiry() async {
    final snap = await fs.collection('enquiries').get();
    expect(snap.docs.length, 1);
    return snap.docs.first.data();
  }

  bool isIso(Object? v) => v is String && DateTime.tryParse(v) != null;

  group('home-page enquiry (EnquiryDataSourceImpl.submitEnquiry)', () {
    test('is written like the website: status Interested + remark + creation history', () async {
      await EnquiryDataSourceImpl(fs).submitEnquiry(const EnquiryEntity(
        name: 'ZZ Test',
        mobile: '9000000000',
        city: 'Test',
        systemType: 'Residential',
        capacity: 'Site assessment requested',
        message: 'please call',
        source: 'home_contact',
        whatsapp: '9000000000',
        state: 'Uttar Pradesh',
        monthlyBill: '2500',
        context: 'Homepage contact form',
      ));
      final d = await onlyEnquiry();
      expect(d['status'], 'Interested'); // not the old, non-CRM 'New'
      expect(d['source'], 'home_contact');
      expect(d['phone'], '9000000000');
      expect(d['remark'], contains('Homepage contact form'));
      expect(d['message'], d['remark']);
      expect(isIso(d['createdAt']), isTrue);
      final history = d['statusHistory'] as List;
      expect(history.length, 1);
      final h = history.first as Map;
      expect(h['status'], 'Interested');
      expect(h['updatedBy'], 'Mobile App');
      expect(isIso(h['updatedAt']), isTrue);
      expect(h['remark'], d['remark']);
    });

    test('an empty message still gets a remark (admin shows one)', () async {
      await EnquiryDataSourceImpl(fs).submitEnquiry(const EnquiryEntity(
        name: 'A',
        mobile: '9000000000',
        city: 'B',
        systemType: 'On Grid',
        capacity: '3KW',
        message: '',
        source: 'bottom_nav',
      ));
      final d = await onlyEnquiry();
      expect((d['remark'] as String).isNotEmpty, isTrue);
      expect(d['status'], 'Interested');
    });
  });

  test('contact-message enquiry also uses the CRM shape', () async {
    await EnquiryDataSourceImpl(fs).submitContactMessage(const ContactMessageEntity(
      name: 'ZZ Test',
      phone: '9000000000',
      email: 'a@b.c',
      message: 'hello',
    ));
    final d = await onlyEnquiry();
    expect(d['status'], 'Interested');
    expect(d['source'], 'contact_form');
    expect((d['statusHistory'] as List).length, 1);
  });

  group('staff enquiries', () {
    final staffDs = () => StaffEnquiriesDataSourceImpl(fs, _MockStorage());

    test('updateEnquiryStatus mirrors the CRM write and appends history', () async {
      final ref = await fs.collection('enquiries').add({
        'name': 'Cust',
        'phone': '9000000001',
        'status': 'Interested',
        'remark': 'first',
        'createdByStaffId': 's1',
        'assignedStaffId': 's1',
        'assignedStaffName': 'Rep One',
        'statusHistory': [
          {'status': 'Interested', 'remark': 'first', 'updatedBy': 'Rep One', 'updatedAt': '2026-10-01T00:00:00.000Z'},
        ],
        'createdAt': '2026-10-01T00:00:00.000Z',
      });

      await staffDs().updateEnquiryStatus(
        enquiryId: ref.id,
        status: 'Paper Received',
        remark: 'papers collected',
        updatedBy: 'Rep One',
      );

      final d = (await ref.get()).data()!;
      expect(d['status'], 'Paper Received');
      expect(d['remark'], 'papers collected');
      // Assignment fields must be left alone (sales can't reassign in the CRM).
      expect(d['assignedStaffId'], 's1');
      expect(d['assignedStaffName'], 'Rep One');
      final history = d['statusHistory'] as List;
      expect(history.length, 2);
      final last = history.last as Map;
      expect(last['status'], 'Paper Received');
      expect(last['remark'], 'papers collected');
      expect(last['updatedBy'], 'Rep One');
      expect(isIso(last['updatedAt']), isTrue);
    });

    test('a second update appends again without losing earlier history', () async {
      final ref = await fs.collection('enquiries').add({
        'status': 'Interested',
        'statusHistory': <Map<String, dynamic>>[],
        'createdAt': '2026-10-01T00:00:00.000Z',
      });
      await staffDs().updateEnquiryStatus(enquiryId: ref.id, status: 'Contacted', remark: 'a', updatedBy: 'X');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await staffDs().updateEnquiryStatus(enquiryId: ref.id, status: 'Site Visit', remark: 'b', updatedBy: 'X');
      final d = (await ref.get()).data()!;
      expect((d['statusHistory'] as List).map((e) => (e as Map)['status']).toList(), ['Contacted', 'Site Visit']);
      expect(d['status'], 'Site Visit');
    });
  });
}

/// Storage isn't touched by these tests (no site photo is attached).
class _MockStorage extends Mock implements FirebaseStorage {}
