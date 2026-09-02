import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );
  
  Future<void> checkCols(List<String> cols) async {
    try {
      await supabase.from('reviews_content').select(cols.join(', ')).limit(1);
      print('Success with: $cols');
    } catch (e) {
      print('Error with $cols: $e');
    }
  }

  await checkCols(['name']);
  await checkCols(['customer_name']);
  await checkCols(['customerName']);
  await checkCols(['major']);
  await checkCols(['customer_major']);
  await checkCols(['customerMajor']);
  await checkCols(['rating']);
  await checkCols(['review_text']);
  await checkCols(['reviewText']);
  await checkCols(['text']);
}
