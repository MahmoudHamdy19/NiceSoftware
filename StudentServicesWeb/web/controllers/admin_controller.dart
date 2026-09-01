import 'dart:html' as html;
import 'dart:convert';
import 'package:supabase/supabase.dart';
import '../views/admin_view.dart';
import '../repositories/request_repository.dart';
import '../repositories/service_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/news_repository.dart';

class AdminController {
  final AdminView _view;
  final SupabaseClient _supabase;
  final RequestRepository _requestRepo;
  final ServiceRepository _serviceRepo;
  final ProjectRepository _projectRepo;
  final ReviewRepository _reviewRepo;
  final NewsRepository _newsRepo;

  AdminController({
    required AdminView view,
    required SupabaseClient supabase,
    required RequestRepository requestRepo,
    required ServiceRepository serviceRepo,
    required ProjectRepository projectRepo,
    required ReviewRepository reviewRepo,
    required NewsRepository newsRepo,
  })  : _view = view,
        _supabase = supabase,
        _requestRepo = requestRepo,
        _serviceRepo = serviceRepo,
        _projectRepo = projectRepo,
        _reviewRepo = reviewRepo,
        _newsRepo = newsRepo {
    _init();
  }

  void _init() {
    _checkAuthState();

    _view.loginForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final emailInput =
          html.document.getElementById('admin-email') as html.InputElement?;
      final passInput =
          html.document.getElementById('admin-password') as html.InputElement?;
      final loginBtn =
          html.document.getElementById('login-btn') as html.ButtonElement?;

      if (emailInput == null || passInput == null) return;

      loginBtn?.disabled = true;
      loginBtn?.text = 'جاري تسجيل الدخول...';

      try {
        await _supabase.auth.signInWithPassword(
          email: emailInput.value ?? '',
          password: passInput.value ?? '',
        );
        await _handleMfaFlow();
      } catch (e, stacktrace) {
        print('Login Error: \$e');
        print(stacktrace);
        _view.showAlert('خطأ في تسجيل الدخول. تأكد من الإيميل والباسوورد. Error: \$e');
      } finally {
        loginBtn?.disabled = false;
        loginBtn?.text = 'دخول';
      }
    });

    _view.logoutBtn?.onClick.listen((_) async {
      await _supabase.auth.signOut();
      _view.showLogin();
    });

    _bindForms();
  }

  String? _currentFactorId;
  String? _currentChallengeId;

  Future<void> _checkAuthState() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _handleMfaFlow();
    } else {
      _view.showLogin();
    }
  }

  Future<void> _handleMfaFlow() async {
    final aalRes = await _supabase.auth.mfa.getAuthenticatorAssuranceLevel();
    if (aalRes.currentLevel == AuthenticatorAssuranceLevels.aal2) {
      _showDashboardAndLoadData();
      return;
    }

    final factorsRes = await _supabase.auth.mfa.listFactors();
    final totpFactors =
        factorsRes.all.where((f) => f.factorType == FactorType.totp);

    if (totpFactors.isNotEmpty) {
      final factor = totpFactors.first;
      _currentFactorId = factor.id;
      try {
        final challenge =
            await _supabase.auth.mfa.challenge(factorId: factor.id);
        _currentChallengeId = challenge.id;
        _view.showMfaVerification();
      } catch (e) {
        _view.showAlert('حدث خطأ في إنشاء تحدي التحقق.');
      }
    } else {
      try {
        final enrollRes =
            await _supabase.auth.mfa.enroll(factorType: FactorType.totp);
        _currentFactorId = enrollRes.id;
        final svgCode = enrollRes.totp?.qrCode;
        if (svgCode == null) {
          _view.showAlert('فشل الحصول على رمز الاستجابة السريعة للتحقق الثنائي.');
          return;
        }
        // Pass SVG string directly to the view to inject into the DOM
        _view.showMfaEnrollment(svgCode);
      } catch (e, st) {
        print('Enroll Error: \$e');
        print(st);
        _view.showAlert('حدث خطأ في إعداد التحقق الثنائي: \$e');
      }
    }
  }

  void _showDashboardAndLoadData() {
    _view.showDashboard();
    _loadRequests();
    _loadServices();
    _loadProjects();
    _loadReviews();
    _loadNews();
  }

  void _bindForms() {
    _view.mfaVerifyForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final codeInput =
          html.document.getElementById('mfa-verify-code') as html.InputElement?;
      final code = codeInput?.value ?? '';
      if (code.length != 6 ||
          _currentFactorId == null ||
          _currentChallengeId == null) return;

      try {
        await _supabase.auth.mfa.verify(
          factorId: _currentFactorId!,
          challengeId: _currentChallengeId!,
          code: code,
        );
        _showDashboardAndLoadData();
      } catch (e) {
        _view.showAlert('الرمز غير صحيح أو منتهي الصلاحية');
      }
    });

    _view.mfaResetBtn?.onClick.listen((event) async {
      event.preventDefault();
      if (_currentFactorId == null) return;
      
      if (_view.confirmAction('هل أنت متأكد من رغبتك في إعادة تعيين التحقق الثنائي؟ سيتم إلغاء التفعيل الحالي.')) {
        try {
          await _supabase.auth.mfa.unenroll(_currentFactorId!);
          _currentFactorId = null;
          _currentChallengeId = null;
          _view.showAlert('تم إعادة التعيين بنجاح. يرجى مسح الرمز الجديد.');
          await _handleMfaFlow();
        } catch (e) {
          _view.showAlert('حدث خطأ أثناء إعادة التعيين: \$e');
        }
      }
    });

    _view.mfaEnrollForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final codeInput =
          html.document.getElementById('mfa-enroll-code') as html.InputElement?;
      final code = codeInput?.value ?? '';
      if (code.length != 6 || _currentFactorId == null) return;

      try {
        final challenge =
            await _supabase.auth.mfa.challenge(factorId: _currentFactorId!);
        await _supabase.auth.mfa.verify(
          factorId: _currentFactorId!,
          challengeId: challenge.id,
          code: code,
        );
        _view.showAlert('تم إعداد التحقق الثنائي بنجاح!');
        _showDashboardAndLoadData();
      } catch (e) {
        _view.showAlert('الرمز غير صحيح.');
      }
    });

    html.document.getElementById('svc-cancel-btn')?.onClick.listen((_) {
      _view.addServiceForm?.reset();
      (html.document.getElementById('svc-edit-id') as html.InputElement).value = '';
      html.document.getElementById('svc-submit-btn')?.text = 'إضافة';
      html.document.getElementById('svc-cancel-btn')?.classes.add('hidden');
    });

    _view.addServiceForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final title = (html.document.getElementById('svc-title') as html.InputElement).value;
      final link = (html.document.getElementById('svc-link') as html.InputElement).value;
      final color = (html.document.getElementById('svc-color') as html.InputElement).value;
      final desc = (html.document.getElementById('svc-desc') as html.TextAreaElement).value;
      final editId = (html.document.getElementById('svc-edit-id') as html.InputElement).value;

      try {
        final formData = {
          'title': title,
          'description': desc,
          'link_url': link,
          'color_var': color,
        };
        if (editId != null && editId.isNotEmpty) {
          await _serviceRepo.updateService(editId, formData);
          _view.showAlert('تم التعديل بنجاح!');
        } else {
          await _serviceRepo.addService(formData);
          _view.showAlert('تمت الإضافة بنجاح!');
        }
        _view.addServiceForm?.reset();
        (html.document.getElementById('svc-edit-id') as html.InputElement).value = '';
        html.document.getElementById('svc-submit-btn')?.text = 'إضافة';
        html.document.getElementById('svc-cancel-btn')?.classes.add('hidden');
        _loadServices();
      } catch (e) {
        _view.showAlert('حدث خطأ: $e');
      }
    });

    html.document.getElementById('proj-cancel-btn')?.onClick.listen((_) {
      _view.addProjectForm?.reset();
      (html.document.getElementById('proj-edit-id') as html.InputElement).value = '';
      html.document.getElementById('proj-submit-btn')?.text = 'إضافة';
      html.document.getElementById('proj-cancel-btn')?.classes.add('hidden');
    });

    _view.addProjectForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final title = (html.document.getElementById('proj-title') as html.InputElement).value;
      final category = (html.document.getElementById('proj-category') as html.InputElement).value;
      final image = (html.document.getElementById('proj-image') as html.InputElement).value;
      final link = (html.document.getElementById('proj-link') as html.TextAreaElement).value;
      final editId = (html.document.getElementById('proj-edit-id') as html.InputElement).value;

      try {
        final formData = {
          'title': title,
          'category': category,
          'image_url': image,
          'link_url': link,
        };
        if (editId != null && editId.isNotEmpty) {
          await _projectRepo.updateProject(editId, formData);
          _view.showAlert('تم التعديل بنجاح!');
        } else {
          await _projectRepo.addProject(formData);
          _view.showAlert('تمت الإضافة بنجاح!');
        }
        _view.addProjectForm?.reset();
        (html.document.getElementById('proj-edit-id') as html.InputElement).value = '';
        html.document.getElementById('proj-submit-btn')?.text = 'إضافة';
        html.document.getElementById('proj-cancel-btn')?.classes.add('hidden');
        _loadProjects();
      } catch (e) {
        _view.showAlert('حدث خطأ: $e');
      }
    });

    html.document.getElementById('rev-cancel-btn')?.onClick.listen((_) {
      _view.addReviewForm?.reset();
      (html.document.getElementById('rev-edit-id') as html.InputElement).value = '';
      html.document.getElementById('rev-submit-btn')?.text = 'إضافة';
      html.document.getElementById('rev-cancel-btn')?.classes.add('hidden');
    });

    _view.addReviewForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final name = (html.document.getElementById('rev-name') as html.InputElement).value;
      final major = (html.document.getElementById('rev-major') as html.InputElement).value;
      final ratingInput = (html.document.getElementById('rev-rating') as html.InputElement).value;
      final text = (html.document.getElementById('rev-text') as html.TextAreaElement).value;
      final editId = (html.document.getElementById('rev-edit-id') as html.InputElement).value;

      int rating = int.tryParse(ratingInput ?? '5') ?? 5;
      if (rating < 1) rating = 1;
      if (rating > 5) rating = 5;

      try {
        final formData = {
          'student_name': name,
          'university': major,
          'rating': rating,
          'review_text': text,
        };
        if (editId != null && editId.isNotEmpty) {
          await _reviewRepo.updateReview(editId, formData);
          _view.showAlert('تم التعديل بنجاح!');
        } else {
          await _reviewRepo.addReview(formData);
          _view.showAlert('تمت إضافة الرأي بنجاح!');
        }
        _view.addReviewForm?.reset();
        (html.document.getElementById('rev-edit-id') as html.InputElement).value = '';
        html.document.getElementById('rev-submit-btn')?.text = 'إضافة';
        html.document.getElementById('rev-cancel-btn')?.classes.add('hidden');
        _loadReviews();
      } catch (e) {
        _view.showAlert('حدث خطأ: $e');
      }
    });

    html.document.getElementById('news-cancel-btn')?.onClick.listen((_) {
      _view.addNewsForm?.reset();
      (html.document.getElementById('news-edit-id') as html.InputElement).value = '';
      html.document.getElementById('news-submit-btn')?.text = 'إضافة';
      html.document.getElementById('news-cancel-btn')?.classes.add('hidden');
    });

    _view.addNewsForm?.onSubmit.listen((event) async {
      event.preventDefault();
      final title = (html.document.getElementById('news-title') as html.InputElement).value;
      final content = (html.document.getElementById('news-content') as html.TextAreaElement).value;
      final editId = (html.document.getElementById('news-edit-id') as html.InputElement).value;

      try {
        final formData = {
          'title': title,
          'content': content,
        };
        if (editId != null && editId.isNotEmpty) {
          await _newsRepo.updateNews(editId, formData);
          _view.showAlert('تم التعديل بنجاح!');
        } else {
          await _newsRepo.addNews(formData);
          _view.showAlert('تمت إضافة الخبر بنجاح!');
        }
        _view.addNewsForm?.reset();
        (html.document.getElementById('news-edit-id') as html.InputElement).value = '';
        html.document.getElementById('news-submit-btn')?.text = 'إضافة';
        html.document.getElementById('news-cancel-btn')?.classes.add('hidden');
        _loadNews();
      } catch (e) {
        _view.showAlert('حدث خطأ: $e');
      }
    });
  }

  Future<void> _loadRequests() async {
    _view.setLoading(_view.tbodyRequests, 8, 'جاري جلب البيانات...');
    try {
      final data = await _requestRepo.getAllRequests();
      _view.renderRequests(data, (id) async {
        await _requestRepo.deleteRequest(id);
      }, (id, status) async {
        try {
          await _requestRepo.updateStatus(id, status);
        } catch (e) {
          _view.showAlert('حدث خطأ أثناء تحديث الحالة: $e');
        }
      });
    } catch (e) {
      _view.setError(_view.tbodyRequests, 8, 'حدث خطأ في جلب البيانات: $e');
    }
  }

  Future<void> _loadServices() async {
    _view.setLoading(_view.tbodyServices, 4, 'جاري جلب الخدمات...');
    try {
      final data = await _serviceRepo.getAllServices();
      _view.renderServices(data, (id) async {
        await _serviceRepo.deleteService(id);
      }, (id) {
        final item = data.firstWhere((s) => s.id == id);
        (html.document.getElementById('svc-title') as html.InputElement).value = item.title;
        (html.document.getElementById('svc-link') as html.InputElement).value = item.linkUrl;
        (html.document.getElementById('svc-color') as html.InputElement).value = item.colorVar;
        (html.document.getElementById('svc-desc') as html.TextAreaElement).value = item.description;
        (html.document.getElementById('svc-edit-id') as html.InputElement).value = item.id;
        html.document.getElementById('svc-submit-btn')?.text = 'تحديث';
        html.document.getElementById('svc-cancel-btn')?.classes.remove('hidden');
        html.document.getElementById('add-service-form')?.scrollIntoView();
      });
    } catch (e) {
      _view.setError(_view.tbodyServices, 4, 'حدث خطأ في جلب الخدمات: \$e');
    }
  }

  Future<void> _loadProjects() async {
    _view.setLoading(_view.tbodyProjects, 4, 'جاري جلب المشاريع...');
    try {
      final data = await _projectRepo.getAllProjects();
      _view.renderProjects(data, (id) async {
        await _projectRepo.deleteProject(id);
      }, (id) {
        final item = data.firstWhere((p) => p.id == id);
        (html.document.getElementById('proj-title') as html.InputElement).value = item.title;
        (html.document.getElementById('proj-category') as html.InputElement).value = item.category;
        (html.document.getElementById('proj-image') as html.InputElement).value = item.imageUrl ?? '';
        (html.document.getElementById('proj-link') as html.TextAreaElement).value = item.linkUrl ?? '';
        (html.document.getElementById('proj-edit-id') as html.InputElement).value = item.id;
        html.document.getElementById('proj-submit-btn')?.text = 'تحديث';
        html.document.getElementById('proj-cancel-btn')?.classes.remove('hidden');
        html.document.getElementById('add-project-form')?.scrollIntoView();
      });
    } catch (e) {
      _view.setError(_view.tbodyProjects, 4, 'حدث خطأ في جلب المشاريع: \$e');
    }
  }

  Future<void> _loadReviews() async {
    _view.setLoading(_view.tbodyReviews, 5, 'جاري جلب الآراء...');
    try {
      final data = await _reviewRepo.getAllReviews();
      _view.renderReviews(data, (id) async {
        await _reviewRepo.deleteReview(id);
      }, (id) {
        final item = data.firstWhere((r) => r.id == id);
        (html.document.getElementById('rev-name') as html.InputElement).value = item.customerName;
        (html.document.getElementById('rev-major') as html.InputElement).value = item.customerMajor;
        (html.document.getElementById('rev-rating') as html.InputElement).value = item.rating.toString();
        (html.document.getElementById('rev-text') as html.TextAreaElement).value = item.reviewText;
        (html.document.getElementById('rev-edit-id') as html.InputElement).value = item.id;
        html.document.getElementById('rev-submit-btn')?.text = 'تحديث';
        html.document.getElementById('rev-cancel-btn')?.classes.remove('hidden');
        html.document.getElementById('add-review-form')?.scrollIntoView();
      });
    } catch (e) {
      _view.setError(_view.tbodyReviews, 5, 'حدث خطأ في جلب الآراء: \$e');
    }
  }

  Future<void> _loadNews() async {
    _view.setLoading(_view.tbodyNews, 4, 'جاري جلب الأخبار...');
    try {
      final data = await _newsRepo.getAllNews();
      _view.renderNews(data, (id) async {
        await _newsRepo.deleteNews(id);
      }, (id) {
        final item = data.firstWhere((n) => n.id == id);
        (html.document.getElementById('news-title') as html.InputElement).value = item.title;
        (html.document.getElementById('news-content') as html.TextAreaElement).value = item.content;
        (html.document.getElementById('news-edit-id') as html.InputElement).value = item.id;
        html.document.getElementById('news-submit-btn')?.text = 'تحديث';
        html.document.getElementById('news-cancel-btn')?.classes.remove('hidden');
        html.document.getElementById('add-news-form')?.scrollIntoView();
      });
    } catch (e) {
      _view.setError(_view.tbodyNews, 4, 'حدث خطأ في جلب الأخبار: \$e');
    }
  }
}
