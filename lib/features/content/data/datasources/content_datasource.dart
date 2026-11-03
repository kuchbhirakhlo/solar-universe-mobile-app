import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/solution_entity.dart';
import '../models/brand_model.dart';
import '../models/faq_model.dart';
import '../models/package_model.dart';
import '../models/project_model.dart';
import 'static_content_data.dart';

abstract class ContentDataSource {
  Future<CompanyInfoEntity> getCompanyInfo();
  Future<List<SolutionEntity>> getSolutions();
  Future<List<PackageModel>> getPackages();
  Future<List<ProjectModel>> getProjects();
  Future<List<FaqModel>> getFaqs();
  Future<List<BrandModel>> getBrands();
}

class ContentDataSourceImpl implements ContentDataSource {
  final FirebaseFirestore firestore;

  ContentDataSourceImpl(this.firestore);

  // No Firestore collection backs company/about copy or the solution-type
  // descriptions — see StaticContentData for why.
  @override
  Future<CompanyInfoEntity> getCompanyInfo() async => StaticContentData.companyInfo;

  @override
  Future<List<SolutionEntity>> getSolutions() async => StaticContentData.solutions;

  @override
  Future<List<PackageModel>> getPackages() async {
    final snap = await firestore.collection('pricing').get();
    return snap.docs.map((d) => PackageModel.fromMap(d.id, d.data())).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final snap =
        await firestore.collection('projects').orderBy('completionDate', descending: true).get();
    return snap.docs.map((d) => ProjectModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<List<FaqModel>> getFaqs() async {
    final snap = await firestore.collection('faq').get();
    return snap.docs.map((d) => FaqModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    final snap = await firestore.collection('brands').get();
    return snap.docs.map((d) => BrandModel.fromMap(d.id, d.data())).toList();
  }
}
