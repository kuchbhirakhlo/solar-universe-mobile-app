import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solaruniverse/features/customer_service_requests/data/datasources/customer_service_requests_datasource.dart';
import 'package:solaruniverse/features/customer_service_requests/data/models/service_request_model.dart';
import 'package:solaruniverse/features/staff_service_requests/data/datasources/staff_service_requests_datasource.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

Map<String, dynamic> _req(
  String engineerId,
  String customerId,
  String createdAt, {
  Object? estimatedCost = 0,
}) =>
    {
      'assignedEngineerId': engineerId,
      'customerId': customerId,
      'customerName': 'c',
      'customerMobile': '9000000000',
      'serviceType': 'Maintenance',
      'description': 'd',
      'status': 'Open',
      'createdAt': createdAt,
      'estimatedCost': estimatedCost,
    };

void main() {
  test('engineer sees only their own requests, newest first, without needing an orderBy index', () async {
    final fs = FakeFirebaseFirestore();
    final reqs = fs.collection('service_requests');
    await reqs.add(_req('eng1', 'c1', '2026-10-06T08:54:41.938Z'));
    await reqs.add(_req('eng1', 'c1', '2026-10-08T13:13:45.299Z'));
    await reqs.add(_req('eng1', 'c1', '2026-10-07T08:02:19.847420Z'));
    await reqs.add(_req('someone-else', 'c1', '2026-10-09T00:00:00.000Z'));

    final list = await StaffServiceRequestsDataSourceImpl(fs, _MockStorage()).getAssignedRequests('eng1');

    expect(list.length, 3);
    expect(list.map((r) => r.createdAt).toList(), [
      '2026-10-08T13:13:45.299Z',
      '2026-10-07T08:02:19.847420Z',
      '2026-10-06T08:54:41.938Z',
    ]);
  });

  test('engineer also sees requests assigned by employeeId (legacy / re-created staff)', () async {
    final fs = FakeFirebaseFirestore();
    final reqs = fs.collection('service_requests');
    await reqs.add(_req('BJCcxHpxkzOQ5doZKtUeVuuwYu52', 'c1', '2026-10-08T13:13:45.299Z'));
    await reqs.add(_req('TSU-EN-0002', 'c1', '2026-10-06T08:54:41.938Z'));
    await reqs.add(_req('someone-else', 'c1', '2026-10-09T00:00:00.000Z'));

    final list = await StaffServiceRequestsDataSourceImpl(fs, _MockStorage()).getAssignedRequests(
      'BJCcxHpxkzOQ5doZKtUeVuuwYu52',
      employeeId: 'TSU-EN-0002',
    );

    expect(list.length, 2);
    expect(list.map((r) => r.assignedEngineerId).toSet(), {
      'BJCcxHpxkzOQ5doZKtUeVuuwYu52',
      'TSU-EN-0002',
    });
    expect(list.first.createdAt, '2026-10-08T13:13:45.299Z');
  });

  test('malformed estimatedCost does not drop the request or empty the list', () async {
    final fs = FakeFirebaseFirestore();
    final reqs = fs.collection('service_requests');
    await reqs.add(_req('eng1', 'c1', '2026-10-08T00:00:00.000Z', estimatedCost: '1500'));
    await reqs.add(_req('eng1', 'c1', '2026-10-07T00:00:00.000Z', estimatedCost: 'not-a-number'));
    await reqs.add(_req('eng1', 'c1', '2026-10-06T00:00:00.000Z', estimatedCost: 200));

    final list = await StaffServiceRequestsDataSourceImpl(fs, _MockStorage()).getAssignedRequests('eng1');

    expect(list.length, 3);
    expect(list.map((r) => r.estimatedCost).toList(), [1500, 0, 200]);
  });

  test('fromMap parses string cost and skips throwing on bad photo field via tryFromMap', () {
    final ok = ServiceRequestModel.fromMap('a', {
      ..._req('eng1', 'c1', '2026-10-08T00:00:00.000Z', estimatedCost: '99.5'),
      'installationPhotos': 'not-a-list',
    });
    expect(ok.estimatedCost, 99.5);
    expect(ok.installationPhotos, isEmpty);

    final skipped = ServiceRequestModel.tryFromMap('b', {
      'assignedEngineerId': 'eng1',
    });
    expect(skipped, isNotNull);
    expect(skipped!.customerName, '');
  });

  test('customer request history is newest first too', () async {
    final fs = FakeFirebaseFirestore();
    final reqs = fs.collection('service_requests');
    await reqs.add(_req('e', 'cust1', '2026-10-01T00:00:00.000Z'));
    await reqs.add(_req('e', 'cust1', '2026-10-05T00:00:00.000Z'));
    await reqs.add(_req('e', 'other', '2026-10-09T00:00:00.000Z'));

    final list = await CustomerServiceRequestsDataSourceImpl(fs).getMyRequests('cust1');

    expect(list.map((r) => r.createdAt).toList(), ['2026-10-05T00:00:00.000Z', '2026-10-01T00:00:00.000Z']);
  });
}
