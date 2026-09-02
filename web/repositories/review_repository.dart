import 'package:supabase/supabase.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _supabase;

  ReviewRepository(this._supabase);

  Future<List<ReviewModel>> getAllReviews() async {
    final response = await _supabase
        .from('reviews_content')
        .select('*')
        .order('created_at', ascending: false);

    final List data = response as List;
    return data
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReview(Map<String, dynamic> data) async {
    await _supabase.from('reviews_content').insert(data);
  }

  Future<void> deleteReview(String id) async {
    await _supabase.from('reviews_content').delete().eq('id', id);
  }

  Future<void> updateReview(String id, Map<String, dynamic> data) async {
    await _supabase.from('reviews_content').update(data).eq('id', id);
  }
}
