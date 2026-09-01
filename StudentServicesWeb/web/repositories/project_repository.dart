import 'package:supabase/supabase.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final SupabaseClient _supabase;

  ProjectRepository(this._supabase);

  Future<List<ProjectModel>> getAllProjects() async {
    final response = await _supabase
        .from('projects_content')
        .select('*')
        .order('created_at', ascending: false);

    final List data = response as List;
    return data
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addProject(Map<String, dynamic> data) async {
    await _supabase.from('projects_content').insert(data);
  }

  Future<void> deleteProject(String id) async {
    await _supabase.from('projects_content').delete().eq('id', id);
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    await _supabase.from('projects_content').update(data).eq('id', id);
  }
}
