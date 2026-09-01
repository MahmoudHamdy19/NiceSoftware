import 'package:supabase/supabase.dart';

class RequestRepository {
  final SupabaseClient _supabase;

  RequestRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final response = await _supabase
        .from('student_requests')
        .select('*')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> deleteRequest(String id) async {
    await _supabase.from('student_requests').delete().eq('id', id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _supabase
        .from('student_requests')
        .update({'status': status})
        .eq('id', id);
  }
}
