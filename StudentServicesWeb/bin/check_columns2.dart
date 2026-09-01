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

  await checkCols(['student_name']);
  await checkCols(['student_major']);
  await checkCols(['university']);
  await checkCols(['college']);
  await checkCols(['specialization']);
  await checkCols(['dept']);
  await checkCols(['department']);
  await checkCols(['faculty']);
}
