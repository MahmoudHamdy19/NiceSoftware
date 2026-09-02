import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );
  try {
    final response = await supabase.from('reviews_content').select('*').limit(1);
    print(response);
  } catch (e) {
    print('Error: $e');
  }
}
