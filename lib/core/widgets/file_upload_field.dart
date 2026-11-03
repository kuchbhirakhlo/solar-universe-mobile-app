import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/file_pick_helper.dart';
import '../utils/staged_file.dart';

/// Document upload field (PAN, Aadhaar, electricity bill, bank proof,
/// property documents) — offers camera / gallery / system file picker, since
/// staff most often photograph these documents in the field rather than
/// already having a saved file. Controlled: the parent owns [files] and
/// receives updates via [onChanged].
class DocumentUploadField extends StatelessWidget {
  final String label;
  final bool required;
  final bool allowMultiple;
  final List<StagedFile> files;
  final ValueChanged<List<StagedFile>> onChanged;
  final String? errorText;

  const DocumentUploadField({
    super.key,
    required this.label,
    required this.files,
    required this.onChanged,
    this.required = false,
    this.allowMultiple = false,
    this.errorText,
  });

  Future<void> _pick(BuildContext context) async {
    final choice = await showModalBottomSheet<_DocumentSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, _DocumentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, _DocumentSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('Choose File'),
              onTap: () => Navigator.pop(context, _DocumentSource.file),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    final result = switch (choice) {
      _DocumentSource.camera =>
        await FilePickHelper.pickImages(allowMultiple: false, source: ImageSource.camera),
      _DocumentSource.gallery =>
        await FilePickHelper.pickImages(allowMultiple: allowMultiple, source: ImageSource.gallery),
      _DocumentSource.file => await FilePickHelper.pickDocuments(allowMultiple: allowMultiple),
    };
    if (result.rejected.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.rejected.join(', ')} exceeded the 10MB limit and were skipped.',
          ),
        ),
      );
    }
    if (result.files.isEmpty) return;
    onChanged(allowMultiple ? [...files, ...result.files] : result.files);
  }

  void _remove(int index) {
    final updated = [...files]..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return _UploadFieldShell(
      label: label,
      required: required,
      hasFiles: files.isNotEmpty,
      errorText: errorText,
      onTap: () => _pick(context),
      emptyHint: 'Camera, gallery, JPG/PNG/PDF · up to 10MB',
      children: [
        for (var i = 0; i < files.length; i++) _FileChip(file: files[i], onRemove: () => _remove(i)),
      ],
    );
  }
}

enum _DocumentSource { camera, gallery, file }

/// Photo upload field (rooftop feasibility photos, site photo) — offers a
/// camera/gallery choice, via image_picker.
class PhotoUploadField extends StatelessWidget {
  final String label;
  final bool required;
  final bool allowMultiple;
  final List<StagedFile> files;
  final ValueChanged<List<StagedFile>> onChanged;
  final String? errorText;
  // When true, skips the camera/gallery choice entirely and opens the
  // camera directly — used where a photo must be proof of being physically
  // on-site right now (e.g. the enquiry site photo), not a pre-existing
  // gallery image.
  final bool cameraOnly;

  const PhotoUploadField({
    super.key,
    required this.label,
    required this.files,
    required this.onChanged,
    this.required = false,
    this.allowMultiple = false,
    this.errorText,
    this.cameraOnly = false,
  });

  Future<void> _pick(BuildContext context) async {
    ImageSource source;
    if (cameraOnly) {
      source = ImageSource.camera;
    } else {
      final chosen = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (chosen == null) return;
      source = chosen;
    }
    final result = await FilePickHelper.pickImages(allowMultiple: allowMultiple, source: source);
    if (result.rejected.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.rejected.join(', ')} exceeded the 10MB limit and were skipped.'),
        ),
      );
    }
    if (result.files.isEmpty) return;
    onChanged(allowMultiple ? [...files, ...result.files] : result.files);
  }

  void _remove(int index) {
    final updated = [...files]..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return _UploadFieldShell(
      label: label,
      required: required,
      hasFiles: files.isNotEmpty,
      errorText: errorText,
      onTap: () => _pick(context),
      emptyHint: cameraOnly ? 'Camera only · up to 10MB' : 'Camera or gallery · up to 10MB',
      children: [
        for (var i = 0; i < files.length; i++) _FileChip(file: files[i], onRemove: () => _remove(i)),
      ],
    );
  }
}

class _UploadFieldShell extends StatelessWidget {
  final String label;
  final bool required;
  final bool hasFiles;
  final String? errorText;
  final VoidCallback onTap;
  final String emptyHint;
  final List<Widget> children;

  const _UploadFieldShell({
    required this.label,
    required this.required,
    required this.hasFiles,
    required this.errorText,
    required this.onTap,
    required this.emptyHint,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: AppTypography.labelMedium,
            children: required
                ? [TextSpan(text: ' *', style: AppTypography.labelMedium.copyWith(color: AppColors.error))]
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.border,
              ),
            ),
            child: hasFiles
                ? Wrap(spacing: 8, runSpacing: 8, children: children)
                : Row(
                    children: [
                      const Icon(Icons.upload_file_rounded, color: AppColors.textTertiary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(emptyHint, style: AppTypography.bodySmall),
                      ),
                      const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                    ],
                  ),
          ),
        ),
        if (hasFiles)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add more'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
            ),
          ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}

class _FileChip extends StatelessWidget {
  final StagedFile file;
  final VoidCallback onRemove;

  const _FileChip({required this.file, required this.onRemove});

  String get _sizeLabel {
    final kb = file.sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($_sizeLabel)',
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
