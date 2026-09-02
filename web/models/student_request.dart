import 'dart:html' as html;

class StudentRequest {
  final Map<String, dynamic> formData;
  final List<html.File> filesToUpload;
  final String sourcePage;

  StudentRequest({
    required this.formData,
    required this.filesToUpload,
    required this.sourcePage,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    for (final entry in formData.entries) {
      // Convert HTML input IDs (hyphens) to DB column names (underscores)
      // e.g. 'input-details' → 'input_details'
      final dbKey = entry.key.replaceAll('-', '_');
      map[dbKey] = entry.value;
    }

    map['source_page'] = sourcePage;
    return map;
  }
}
