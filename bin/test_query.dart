import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );
  
  final res = await supabase.from('student_requests').select('*').limit(1);
  if (res.isNotEmpty) {
    print(res.first.keys);
  } else {
    print('No data');
  }
}
