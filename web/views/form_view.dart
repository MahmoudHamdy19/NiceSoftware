import 'dart:html' as html;
import '../models/student_request.dart';

class FormView {
  final html.FormElement _form;
  html.ButtonElement? _submitBtn;
  String _originalBtnText = 'إرسال الطلب';

  FormView(this._form) {
    _submitBtn =
        _form.querySelector('button[type="submit"]') as html.ButtonElement?;
    if (_submitBtn != null) {
      _originalBtnText = _submitBtn!.text ?? 'إرسال الطلب';
    }
  }

  void onFormSubmit(Function(StudentRequest) onSubmitHandler) {
    _form.onSubmit.listen((event) {
      event.preventDefault();
      final request = _extractFormData();
      onSubmitHandler(request);
    });
  }

  StudentRequest _extractFormData() {
    final inputs = _form.querySelectorAll('input, select, textarea');
    final Map<String, dynamic> data = {};
    List<html.File> files = [];

    // Track the university "other" text field separately
    String? universityOtherVal;

    for (final element in inputs) {
      String? key;
      String? val;

      if (element is html.InputElement) {
        if (element.type == 'file') {
          if (element.files != null) {
            files.addAll(element.files!);
          }
          continue;
        }
        key = element.getAttribute('name') ?? element.id;
        val = element.value;

        // Capture the "other university" text separately
        if (key == 'input-university-other') {
          universityOtherVal = (val != null && val.isNotEmpty) ? val : null;
          continue; // handled below
        }
      } else if (element is html.SelectElement) {
        key = element.id;
        val = element.value;
      } else if (element is html.TextAreaElement) {
        key = element.getAttribute('name') ?? element.id;
        val = element.value;
      }

      // Skip hidden helper fields
      if (key == null || key.isEmpty || key == 'form-type') continue;

      // Store every input-* field; skip empty values for non-required fields
      if (val != null && val.isNotEmpty) {
        data[key] = val;
      }
    }

    // If the university dropdown was "other", override with the typed value
    if (data['input-university'] == 'other' && universityOtherVal != null) {
      data['input-university'] = universityOtherVal;
    }
    // Also persist the raw "other" text into its own DB column
    if (universityOtherVal != null) {
      data['input-university-other'] = universityOtherVal;
    }

    return StudentRequest(
      formData: data,
      filesToUpload: files,
      sourcePage: html.window.location.pathname ?? 'unknown',
    );
  }

  void setLoading(bool isLoading) {
    if (_submitBtn != null) {
      _submitBtn!.disabled = isLoading;
      _submitBtn!.text = isLoading ? 'جاري الإرسال...' : _originalBtnText;
    }
  }

  void showSuccess(String message) {
    html.window.alert(message);
    _form.reset();
  }

  void showError(String error) {
    html.window.alert('عذراً، حدث خطأ أثناء الإرسال. التفاصيل: $error');
  }
}
