import 'package:supabase/supabase.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepository(this._supabase);

  Future<List<ServiceModel>> getAllServices() async {
    final response = await _supabase
        .from('services_content')
        .select('*')
        .order('created_at', ascending: true);

    final List data = response as List;
    return data
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addService(Map<String, dynamic> data) async {
    await _supabase.from('services_content').insert(data);
  }

  Future<void> deleteService(String id) async {
    await _supabase.from('services_content').delete().eq('id', id);
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _supabase.from('services_content').update(data).eq('id', id);
  }
}
