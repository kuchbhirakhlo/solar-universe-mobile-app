import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/staff_quotations_repository.dart';
import '../models/quotation_model.dart';

abstract class StaffQuotationsDataSource {
  Future<List<QuotationModel>> getQuotations({required String staffId});
  Future<QuotationModel> createQuotation(
    NewQuotation quotation, {
    required String preparedBy,
    required String staffId,
  });
}

class StaffQuotationsDataSourceImpl implements StaffQuotationsDataSource {
  final FirebaseFirestore firestore;

  StaffQuotationsDataSourceImpl(this.firestore);

  @override
  Future<List<QuotationModel>> getQuotations({required String staffId}) async {
    final snap = await firestore
        .collection('quotations')
        .where('createdByStaffId', isEqualTo: staffId)
        .get();
    // Sorted here rather than with .orderBy('createdAt'): that combined with the
    // equality filter needs a composite index which isn't deployed, and an
    // un-indexed query fails outright (FAILED_PRECONDITION) — the screen then
    // shows "could not load". createdAt is an ISO-8601 string, so it sorts
    // correctly as text.
    final list = snap.docs.map((d) => QuotationModel.fromMap(d.id, d.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<String> _nextQuotationNumber() async {
    final snap = await firestore.collection('quotations').count().get();
    final next = (snap.count ?? 0) + 1;
    return 'SWT/E/${next.toString().padLeft(4, '0')}';
  }

  @override
  Future<QuotationModel> createQuotation(
    NewQuotation quotation, {
    required String preparedBy,
    required String staffId,
  }) async {
    final quotationNumber = await _nextQuotationNumber();
    final createdAt = DateTime.now().toUtc().toIso8601String();
    final data = {
      'customerName': quotation.customerName,
      'phone': quotation.phone,
      'solarSystem': quotation.solarSystem,
      'capacity': quotation.capacity,
      'products': quotation.products,
      'items': quotation.items.map((e) => e.toMap()).toList(),
      'price': quotation.price,
      'gst': quotation.gst,
      'discount': quotation.discount,
      'finalAmount': quotation.finalAmount,
      'quotationNumber': quotationNumber,
      'preparedBy': preparedBy,
      'createdByStaffId': staffId,
      'createdAt': createdAt,
    };
    final ref = await firestore.collection('quotations').add(data);
    return QuotationModel.fromMap(ref.id, data);
  }
}
