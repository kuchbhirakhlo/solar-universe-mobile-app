import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'staged_file.dart';

/// Picking + client-side validation for document/photo uploads (PAN,
/// Aadhaar, electricity bill, bank proof, property documents, site/rooftop
/// photos). Enforces the spec's 10MB-per-file limit and jpg/jpeg/png/pdf
/// formats up front, before anything reaches Firebase Storage.
class FilePickHelper {
  FilePickHelper._();

  static const int maxSizeBytes = 10 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  /// Documents (PAN, Aadhaar side, electricity bill, bank proof, property
  /// docs) — images or PDF, via the system file picker.
  static Future<FilePickResult> pickDocuments({required bool allowMultiple}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      withReadStream: false,
    );
    if (result == null) return FilePickResult.empty;

    final files = <StagedFile>[];
    final rejected = <String>[];
    for (final f in result.files) {
      if (f.path == null) continue;
      final size = f.size;
      if (size > maxSizeBytes) {
        rejected.add(f.name);
        continue;
      }
      files.add(StagedFile(name: f.name, path: f.path!, sizeBytes: size));
    }
    return FilePickResult(files: files, rejected: rejected);
  }

  /// Photos (rooftop feasibility, site photo) — camera or gallery.
  static Future<FilePickResult> pickImages({
    required bool allowMultiple,
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final List<XFile> picked;
    if (allowMultiple && source == ImageSource.gallery) {
      picked = await picker.pickMultiImage(imageQuality: 85);
    } else {
      final single = await picker.pickImage(source: source, imageQuality: 85);
      picked = single == null ? [] : [single];
    }
    if (picked.isEmpty) return FilePickResult.empty;

    final files = <StagedFile>[];
    final rejected = <String>[];
    for (final xfile in picked) {
      final size = await File(xfile.path).length();
      if (size > maxSizeBytes) {
        rejected.add(xfile.name);
        continue;
      }
      files.add(StagedFile(name: xfile.name, path: xfile.path, sizeBytes: size));
    }
    return FilePickResult(files: files, rejected: rejected);
  }
}
