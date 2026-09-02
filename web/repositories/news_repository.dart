import 'package:supabase/supabase.dart';
import '../models/news_model.dart';

class NewsRepository {
  final SupabaseClient _supabase;

  NewsRepository(this._supabase);

  Future<List<NewsModel>> getAllNews() async {
    final response = await _supabase
        .from('news_content')
        .select('*')
        .order('created_at', ascending: false);

    final List data = response as List;
    return data
        .map((json) => NewsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addNews(Map<String, dynamic> data) async {
    await _supabase.from('news_content').insert(data);
  }

  Future<void> deleteNews(String id) async {
    await _supabase.from('news_content').delete().eq('id', id);
  }

  Future<void> updateNews(String id, Map<String, dynamic> data) async {
    await _supabase.from('news_content').update(data).eq('id', id);
  }
}
