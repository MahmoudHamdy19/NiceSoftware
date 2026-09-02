import 'dart:html' as html;
import 'services/supabase_service.dart';
import 'routes/router.dart';

void main() {
  final supabaseService = SupabaseService(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );

  final appRoot = html.document.getElementById('app-root');
  if (appRoot != null) {
    SpaRouter(appRoot, supabaseService);
  } else {
    html.window.console.error('App root container not found!');
  }
}
