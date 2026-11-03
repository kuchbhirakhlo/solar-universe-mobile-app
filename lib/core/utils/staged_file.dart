class StagedFile {
  final String name;
  final String path;
  final int sizeBytes;

  const StagedFile({required this.name, required this.path, required this.sizeBytes});
}

class FilePickResult {
  final List<StagedFile> files;
  final List<String> rejected;

  const FilePickResult({required this.files, this.rejected = const []});

  static const empty = FilePickResult(files: []);
}
