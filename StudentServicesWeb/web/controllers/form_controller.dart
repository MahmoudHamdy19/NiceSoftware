import '../models/student_request.dart';
import '../views/form_view.dart';
import '../services/supabase_service.dart';

class FormController {
  final FormView view;
  final SupabaseService service;

  FormController(this.view, this.service) {
    view.onFormSubmit(_handleSubmission);
  }

  Future<void> _handleSubmission(StudentRequest request) async {
    view.setLoading(true);
    try {
      await service.submitRequest(request);
      view.showSuccess('تم إرسال طلبك بنجاح! فريقنا بيتواصل معك قريب.');
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.setLoading(false);
    }
  }
}
