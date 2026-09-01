import 'dart:html' as html;
import 'dart:typed_data';
import 'package:supabase/supabase.dart';
import '../models/student_request.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(String url, String anonKey)
      : _client = SupabaseClient(url, anonKey);

  SupabaseClient get client => _client;

  Future<void> submitRequest(StudentRequest request) async {
    List<String> fileUrls = [];

    for (final file in request.filesToUpload) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final Uint8List bytes = reader.result as Uint8List;

      await _client.storage.from('student_files').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: file.type),
          );

      final publicUrl =
          _client.storage.from('student_files').getPublicUrl(fileName);
      fileUrls.add(publicUrl);
    }

    final dbData = request.toMap();
    if (fileUrls.isNotEmpty) {
      dbData['uploaded_files'] = fileUrls.join(', ');
    }

    await _client.from('student_requests').insert(dbData);
  }
}
