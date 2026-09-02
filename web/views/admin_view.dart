import 'dart:html' as html;
import '../models/service_model.dart';
import '../models/project_model.dart';
import '../models/review_model.dart';
import '../models/news_model.dart';

class AdminView {
  final html.Element? loginSection =
      html.document.getElementById('login-section');
  final html.Element? dashboardSection =
      html.document.getElementById('dashboard-section');
  final html.Element? tbodyRequests =
      html.document.getElementById('requests-tbody');
  final html.Element? tbodyServices =
      html.document.getElementById('services-tbody');
  final html.Element? tbodyProjects =
      html.document.getElementById('projects-tbody');
  final html.Element? tbodyReviews =
      html.document.getElementById('reviews-tbody');
  final html.Element? tbodyNews = html.document.getElementById('news-tbody');

  final html.FormElement? loginForm =
      html.document.getElementById('admin-login-form') as html.FormElement?;
  final html.FormElement? addServiceForm =
      html.document.getElementById('add-service-form') as html.FormElement?;
  final html.FormElement? addProjectForm =
      html.document.getElementById('add-project-form') as html.FormElement?;
  final html.FormElement? addReviewForm =
      html.document.getElementById('add-review-form') as html.FormElement?;
  final html.FormElement? addNewsForm =
      html.document.getElementById('add-news-form') as html.FormElement?;
  final html.Element? logoutBtn = html.document.getElementById('logout-btn');

  final html.Element? mfaVerifySection =
      html.document.getElementById('mfa-verify-section');
  final html.Element? mfaEnrollSection =
      html.document.getElementById('mfa-enroll-section');
  final html.FormElement? mfaVerifyForm =
      html.document.getElementById('mfa-verify-form') as html.FormElement?;
  final html.Element? mfaResetBtn = 
      html.document.getElementById('mfa-reset-btn');
  final html.FormElement? mfaEnrollForm =
      html.document.getElementById('mfa-enroll-form') as html.FormElement?;
  final html.Element? qrCodeContainer =
      html.document.getElementById('qr-code-container');

  AdminView() {
    _initTabs();
  }

  void _initTabs() {
    final tabBtns = html.document.querySelectorAll('.tab-btn');
    for (final btn in tabBtns) {
      btn.onClick.listen((e) {
        for (final b in tabBtns) {
          b.classes.remove('active');
          b.style.background = 'transparent';
          b.style.border = '1px solid var(--primary-color)';
        }
        final clicked = e.target as html.Element;
        clicked.classes.add('active');
        clicked.style.background = 'var(--primary-color)';
        clicked.style.border = 'none';

        final contents = html.document.querySelectorAll('.tab-content');
        for (final content in contents) {
          content.classes.add('hidden');
        }

        final targetId = clicked.getAttribute('data-target');
        if (targetId != null) {
          html.document.getElementById(targetId)?.classes.remove('hidden');
        }
      });
    }
  }

  void _hideAllSections() {
    loginSection?.classes.add('hidden');
    dashboardSection?.classes.add('hidden');
    mfaVerifySection?.classes.add('hidden');
    mfaEnrollSection?.classes.add('hidden');
  }

  void showLogin() {
    _hideAllSections();
    loginSection?.classes.remove('hidden');
  }

  void showMfaVerification() {
    _hideAllSections();
    mfaVerifySection?.classes.remove('hidden');
  }

  void showMfaEnrollment(String svgCode) {
    _hideAllSections();
    if (qrCodeContainer != null) {
      qrCodeContainer!.setInnerHtml(svgCode, treeSanitizer: html.NodeTreeSanitizer.trusted);
    }
    mfaEnrollSection?.classes.remove('hidden');
  }

  void showDashboard() {
    _hideAllSections();
    dashboardSection?.classes.remove('hidden');
  }

  void showAlert(String message) {
    html.window.alert(message);
  }

  bool confirmAction(String message) {
    return html.window.confirm(message) ?? false;
  }

  // Set Loading States
  void setLoading(html.Element? tbody, int colspan, String text) {
    if (tbody == null) return;
    tbody.innerHtml =
        '<tr><td colspan="$colspan" style="text-align: center; padding: 30px;"><div class="loader"></div><p style="margin-top: 15px;">$text</p></td></tr>';
  }

  void setError(html.Element? tbody, int colspan, String error) {
    if (tbody == null) return;
    tbody.innerHtml =
        '<tr><td colspan="$colspan" style="text-align: center; color: red;">$error</td></tr>';
  }

  // Status helpers
  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'جاري التنفيذ';
      case 'completed':   return 'مكتمل';
      case 'cancelled':   return 'ملغي';
      default:            return 'قيد الانتظار';
    }
  }

  String _statusStyle(String status) {
    switch (status) {
      case 'in_progress': return 'background:rgba(234,179,8,0.2);color:#fbbf24;border:1px solid rgba(234,179,8,0.4);';
      case 'completed':   return 'background:rgba(34,197,94,0.2);color:#4ade80;border:1px solid rgba(34,197,94,0.4);';
      case 'cancelled':   return 'background:rgba(239,68,68,0.2);color:#f87171;border:1px solid rgba(239,68,68,0.4);';
      default:            return 'background:rgba(99,102,241,0.2);color:#a5b4fc;border:1px solid rgba(99,102,241,0.4);';
    }
  }

  String _buildStatusBadge(String status) {
    return '<span style="display:inline-block;padding:3px 10px;border-radius:20px;font-size:0.82rem;font-weight:600;${_statusStyle(status)}">${_statusLabel(status)}</span>';
  }

  String _buildStatusDropdown(String id, String current) {
    final options = {
      'pending':     'قيد الانتظار',
      'in_progress': 'جاري التنفيذ',
      'completed':   'مكتمل',
      'cancelled':   'ملغي',
    };
    String opts = '';
    options.forEach((val, label) {
      final selected = val == current ? 'selected' : '';
      opts += '<option value="$val" $selected>$label</option>';
    });
    return '''
      <select class="status-select" data-id="$id"
        style="margin-top:8px;background:rgba(0,0,0,0.3);color:#e2e8f0;
               border:1px solid rgba(255,255,255,0.15);border-radius:8px;
               padding:4px 8px;font-size:0.82rem;cursor:pointer;width:100%;">
        $opts
      </select>''';
  }

  // Render Requests
  void renderRequests(
      List<Map<String, dynamic>> requests,
      Function(String) onDelete,
      Function(String, String) onStatusChange) {
    if (tbodyRequests == null) return;
    tbodyRequests!.innerHtml = '';

    if (requests.isEmpty) {
      tbodyRequests!.innerHtml =
          '<tr><td colspan="8" style="text-align: center;">لا توجد طلبات حتى الآن.</td></tr>';
      return;
    }

    for (var request in requests) {
      final tr = html.Element.tr();
      final String id = request['id'].toString();
      final String date = request['created_at'].toString().split('T').first;
      final String status = request['status']?.toString() ?? 'pending';

      // قراءة البيانات مع دعم الأعمدة القديمة والجديدة
      final String name = request['input_name'] ?? request['input-name'] ?? 'غير معروف';
      final String phone = request['input_phone'] ?? request['input-phone'] ?? 'لا يوجد';
      final String uni = request['input_university'] ?? request['input-university'] ?? 'غير معروف';
      final String page = request['source_page'] ?? '';

      // بناء تفاصيل الطلب
      String details = '';
      final service = request['input_service'] ?? request['input-service'];
      final reqDetails = request['input_details'] ?? request['input-details'];
      final course = request['input_course'] ?? request['input-course'];
      final projectName = request['input_project_name'] ?? request['input-project-name'];
      final technologies = request['input_technologies'] ?? request['input-technologies'];
      final subject = request['input_subject'] ?? request['input-subject'];
      final deadline = request['input_deadline'] ?? request['input-deadline'];
      final email = request['input_email'];

      if (service != null)      details += '<b>الخدمة:</b> $service<br>';
      if (reqDetails != null)   details += '<b>التفاصيل:</b> $reqDetails<br>';
      if (course != null)       details += '<b>الكورس:</b> $course<br>';
      if (projectName != null)  details += '<b>المشروع:</b> $projectName<br>';
      if (technologies != null) details += '<b>التقنيات:</b> $technologies<br>';
      if (subject != null)      details += '<b>المادة:</b> $subject<br>';
      if (deadline != null)     details += '<b>موعد التسليم:</b> $deadline<br>';
      if (email != null)        details += '<b>الإيميل:</b> $email<br>';
      if (details.isEmpty)      details = '-';

      final filesHtml = _buildFilesHtml(request['uploaded_files']?.toString());

      tr.setInnerHtml('''
        <td>$date<br><small style="opacity:0.6">$page</small></td>
        <td>$name</td>
        <td dir="ltr">$phone</td>
        <td>$uni</td>
        <td>$details</td>
        <td>$filesHtml</td>
        <td>
          ${_buildStatusBadge(status)}
          ${_buildStatusDropdown(id, status)}
        </td>
        <td><button class="btn-primary btn-small delete-req-btn" data-id="$id">حذف</button></td>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      tbodyRequests!.children.add(tr);
    }

    _bindDeleteButtons(tbodyRequests!, '.delete-req-btn', onDelete,
        'هل أنت متأكد من حذف هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.');

    // Bind status dropdowns
    final selects = tbodyRequests!.querySelectorAll('.status-select');
    for (final sel in selects) {
      sel.onChange.listen((event) {
        final selectEl = sel as html.SelectElement;
        final reqId = selectEl.getAttribute('data-id');
        final newStatus = selectEl.value ?? 'pending';
        if (reqId != null) {
          onStatusChange(reqId, newStatus);
          // Update badge immediately for instant visual feedback
          final badge = selectEl.previousElementSibling;
          if (badge != null) {
            badge.setInnerHtml(_buildStatusBadge(newStatus),
                treeSanitizer: html.NodeTreeSanitizer.trusted);
          }
        }
      });
    }
  }


  // Render Services
  void renderServices(List<ServiceModel> services, Function(String) onDelete, Function(String) onEdit) {
    if (tbodyServices == null) return;
    tbodyServices!.innerHtml = '';

    if (services.isEmpty) {
      tbodyServices!.innerHtml =
          '<tr><td colspan="4" style="text-align: center;">لا توجد خدمات مضافة حتى الآن.</td></tr>';
      return;
    }

    for (var service in services) {
      final tr = html.Element.tr();
      tr.setInnerHtml('''
        <td>${service.title}</td>
        <td>${service.description}</td>
        <td dir="ltr">${service.linkUrl}</td>
        <td>
          <button class="btn-primary btn-small edit-svc-btn" data-id="${service.id}" style="background: #0ea5e9; margin-left: 5px;">تعديل</button>
          <button class="btn-primary btn-small delete-svc-btn" data-id="${service.id}">حذف</button>
        </td>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);
      tbodyServices!.children.add(tr);
    }
    _bindDeleteButtons(tbodyServices!, '.delete-svc-btn', onDelete,
        'هل أنت متأكد من حذف هذه الخدمة من الموقع؟');
    _bindEditButtons(tbodyServices!, '.edit-svc-btn', onEdit);
  }

  // Render Projects
  void renderProjects(List<ProjectModel> projects, Function(String) onDelete, Function(String) onEdit) {
    if (tbodyProjects == null) return;
    tbodyProjects!.innerHtml = '';

    if (projects.isEmpty) {
      tbodyProjects!.innerHtml =
          '<tr><td colspan="4" style="text-align: center;">لا توجد مشاريع مضافة حتى الآن.</td></tr>';
      return;
    }

    for (var project in projects) {
      final tr = html.Element.tr();
      tr.setInnerHtml('''
        <td>${project.title}</td>
        <td dir="ltr">${project.category}</td>
        <td><a href="${project.imageUrl}" target="_blank" style="color: var(--primary-color);">عرض الصورة</a></td>
        <td>
          <button class="btn-primary btn-small edit-proj-btn" data-id="${project.id}" style="background: #0ea5e9; margin-left: 5px;">تعديل</button>
          <button class="btn-primary btn-small delete-proj-btn" data-id="${project.id}">حذف</button>
        </td>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);
      tbodyProjects!.children.add(tr);
    }
    _bindDeleteButtons(tbodyProjects!, '.delete-proj-btn', onDelete,
        'هل أنت متأكد من حذف هذا المشروع؟');
    _bindEditButtons(tbodyProjects!, '.edit-proj-btn', onEdit);
  }

  // Render Reviews
  void renderReviews(List<ReviewModel> reviews, Function(String) onDelete, Function(String) onEdit) {
    if (tbodyReviews == null) return;
    tbodyReviews!.innerHtml = '';

    if (reviews.isEmpty) {
      tbodyReviews!.innerHtml =
          '<tr><td colspan="5" style="text-align: center;">لا توجد آراء مضافة حتى الآن.</td></tr>';
      return;
    }

    for (var review in reviews) {
      final tr = html.Element.tr();
      final stars = '\u2605' * review.rating + '\u2606' * (5 - review.rating);
      tr.setInnerHtml('''
        <td>${review.customerName}</td>
        <td>${review.customerMajor}</td>
        <td dir="ltr">$stars</td>
        <td>${review.reviewText}</td>
        <td>
          <button class="btn-primary btn-small edit-rev-btn" data-id="${review.id}" style="background: #0ea5e9; margin-left: 5px;">تعديل</button>
          <button class="btn-primary btn-small delete-rev-btn" data-id="${review.id}">حذف</button>
        </td>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);
      tbodyReviews!.children.add(tr);
    }
    _bindDeleteButtons(tbodyReviews!, '.delete-rev-btn', onDelete,
        'هل أنت متأكد من حذف هذا الرأي؟');
    _bindEditButtons(tbodyReviews!, '.edit-rev-btn', onEdit);
  }

  // Render News
  void renderNews(List<NewsModel> newsList, Function(String) onDelete, Function(String) onEdit) {
    if (tbodyNews == null) return;
    tbodyNews!.innerHtml = '';

    if (newsList.isEmpty) {
      tbodyNews!.innerHtml =
          '<tr><td colspan="4" style="text-align: center;">لا توجد أخبار مضافة حتى الآن.</td></tr>';
      return;
    }

    for (var news in newsList) {
      final tr = html.Element.tr();
      final String date = news.createdAt?.toString().split('T').first ?? '';
      tr.setInnerHtml('''
        <td>$date</td>
        <td>${news.title}</td>
        <td>${news.content}</td>
        <td>
          <button class="btn-primary btn-small edit-news-btn" data-id="${news.id}" style="background: #0ea5e9; margin-left: 5px;">تعديل</button>
          <button class="btn-primary btn-small delete-news-btn" data-id="${news.id}">حذف</button>
        </td>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);
      tbodyNews!.children.add(tr);
    }
    _bindDeleteButtons(tbodyNews!, '.delete-news-btn', onDelete,
        'هل أنت متأكد من حذف هذا الخبر؟');
    _bindEditButtons(tbodyNews!, '.edit-news-btn', onEdit);
  }

  void _bindEditButtons(
      html.Element container, String selector, Function(String) onEdit) {
    final buttons = container.querySelectorAll(selector);
    for (final btn in buttons) {
      btn.onClick.listen((event) {
        final btnElement = event.target as html.Element;
        final id = btnElement.getAttribute('data-id');
        if (id != null) {
          onEdit(id);
        }
      });
    }
  }

  void _bindDeleteButtons(html.Element container, String selector,
      Function(String) onDelete, String confirmMsg) {
    final buttons = container.querySelectorAll(selector);
    for (final btn in buttons) {
      btn.onClick.listen((event) {
        if (confirmAction(confirmMsg)) {
          final btnElement = event.target as html.Element;
          final id = btnElement.getAttribute('data-id');
          if (id != null) {
            btnElement.text = '...';
            onDelete(id).then((_) {
              btnElement.parent?.parent?.remove();
            }).catchError((e) {
              showAlert('حدث خطأ أثناء الحذف');
              btnElement.text = 'حذف';
            });
          }
        }
      });
    }
  }

  String _buildFilesHtml(String? filesStr) {
    if (filesStr == null || filesStr.isEmpty || filesStr == 'null')
      return 'لا يوجد';
    final urls = filesStr.split(', ');
    String result = '';
    for (int i = 0; i < urls.length; i++) {
      result +=
          '<a href="${urls[i]}" target="_blank" style="color: var(--primary-color); text-decoration: underline;">ملف ${i + 1}</a><br>';
    }
    return result;
  }
}
