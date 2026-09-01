import 'package:supabase/supabase.dart';
import 'views/admin_view.dart';
import 'controllers/admin_controller.dart';
import 'repositories/request_repository.dart';
import 'repositories/service_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/news_repository.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );

  final view = AdminView();

  AdminController(
    view: view,
    supabase: supabase,
    requestRepo: RequestRepository(supabase),
    serviceRepo: ServiceRepository(supabase),
    projectRepo: ProjectRepository(supabase),
    reviewRepo: ReviewRepository(supabase),
    newsRepo: NewsRepository(supabase),
  );
}
