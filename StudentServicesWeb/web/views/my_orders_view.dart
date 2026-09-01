import 'dart:html' as html;

class MyOrdersView {
  final html.FormElement? searchForm;
  final html.InputElement? phoneInput;
  final html.ButtonElement? searchBtn;
  final html.Element? resultsSection;
  final html.Element? ordersContainer;

  // Callback: (orderId, studentName, university, rating, reviewText) -> void
  Function(String, String, String, int, String)? _onReviewSubmit;

  MyOrdersView()
      : searchForm = html.document.getElementById('search-orders-form') as html.FormElement?,
        phoneInput = html.document.getElementById('search-phone') as html.InputElement?,
        searchBtn = html.document.getElementById('search-btn') as html.ButtonElement?,
        resultsSection = html.document.getElementById('orders-results'),
        ordersContainer = html.document.getElementById('orders-container');

  void onSearchSubmit(Function(String) onSubmitHandler) {
    searchForm?.onSubmit.listen((event) {
      event.preventDefault();
      final phone = phoneInput?.value;
      if (phone != null && phone.isNotEmpty) {
        onSubmitHandler(phone);
      }
    });
  }

  void onReviewSubmit(Function(String, String, String, int, String) handler) {
    _onReviewSubmit = handler;
  }

  void setLoading(bool isLoading) {
    if (searchBtn != null) {
      searchBtn!.disabled = isLoading;
      searchBtn!.text = isLoading ? 'جاري البحث...' : 'بحث';
    }
  }

  // Status helpers
  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'جاري التنفيذ';
      case 'completed':   return 'مكتمل ✓';
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

  void renderOrders(List<Map<String, dynamic>> orders) {
    if (resultsSection == null || ordersContainer == null) return;
    
    resultsSection!.style.display = 'block';
    ordersContainer!.innerHtml = '';

    if (orders.isEmpty) {
      ordersContainer!.innerHtml = '<div class="glass-card" style="text-align: center;"><p>لم يتم العثور على طلبات مرتبطة بهذا الرقم.</p></div>';
      return;
    }

    for (var order in orders) {
      final card = html.Element.div()..className = 'glass-card';
      
      final String date = order['created_at'].toString().split('T').first;
      final String id = order['id'].toString();
      final String status = order['status']?.toString() ?? 'pending';
      final String studentName = order['input_name']?.toString() ?? '';
      final String university = order['input_university']?.toString() ?? '';
      
      String detailsHtml = '<ul>';
      if ((order['input_service'] ?? order['input-service']) != null) detailsHtml += '<li><strong>الخدمة:</strong> ${order['input_service'] ?? order['input-service']}</li>';
      if ((order['input_details'] ?? order['input-details']) != null) detailsHtml += '<li><strong>التفاصيل:</strong> ${order['input_details'] ?? order['input-details']}</li>';
      if ((order['input_course'] ?? order['input-course']) != null) detailsHtml += '<li><strong>الدورة:</strong> ${order['input_course'] ?? order['input-course']}</li>';
      if ((order['input_project_name'] ?? order['input-project-name']) != null) detailsHtml += '<li><strong>المشروع:</strong> ${order['input_project_name'] ?? order['input-project-name']}</li>';
      if ((order['input_technologies'] ?? order['input-technologies']) != null) detailsHtml += '<li><strong>التقنيات:</strong> ${order['input_technologies'] ?? order['input-technologies']}</li>';
      if ((order['input_subject'] ?? order['input-subject']) != null) detailsHtml += '<li><strong>المادة:</strong> ${order['input_subject'] ?? order['input-subject']}</li>';
      if ((order['input_deadline'] ?? order['input-deadline']) != null) detailsHtml += '<li><strong>موعد التسليم:</strong> ${order['input_deadline'] ?? order['input-deadline']}</li>';
      detailsHtml += '</ul>';

      final String filesStr = order['uploaded_files']?.toString() ?? '';
      String filesHtml = '<p><strong>الملفات المرفوعة:</strong> لا توجد ملفات</p>';
      
      if (filesStr.isNotEmpty && filesStr != 'null') {
        final urls = filesStr.split(', ');
        filesHtml = '<p><strong>الملفات المرفوعة:</strong></p><ul style="list-style: none; padding-right: 0;">';
        for (int i = 0; i < urls.length; i++) {
          filesHtml += '<li><a href="${urls[i]}" target="_blank" style="color: var(--primary-color); text-decoration: underline;">عرض الملف ${i + 1}</a></li>';
        }
        filesHtml += '</ul>';
      }

      // Set main card content (header + details + files)
      card.setInnerHtml('''
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
          <h4 style="color: var(--primary-color); margin: 0;">طلب رقم #${id.substring(0, 8)}...</h4>
          <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
            <span style="display:inline-block;padding:5px 14px;border-radius:20px;font-size:0.9rem;font-weight:700;${_statusStyle(status)}">${_statusLabel(status)}</span>
            <span style="font-size: 0.9em; opacity: 0.8;">تاريخ الطلب: $date</span>
          </div>
        </div>
        <div style="margin-bottom: 15px;">
          $detailsHtml
        </div>
        <div style="margin-bottom: 15px;">
          $filesHtml
        </div>
      ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      // Append review section separately for completed orders to avoid
      // the HTML parser silently dropping nested elements in one big block.
      if (status == 'completed') {
        card.appendHtml(
          _buildReviewSection(id, studentName, university),
          treeSanitizer: html.NodeTreeSanitizer.trusted,
        );
        _setupReviewCard(card, id, studentName, university);
      }

      ordersContainer!.children.add(card);
    }
  }

  String _buildReviewSection(String orderId, String studentName, String university) {
    return '''
      <div id="review-section-$orderId" style="border-top: 1px solid rgba(255,255,255,0.1); padding-top: 15px; margin-top: 5px;">
        <button id="review-btn-$orderId"
          style="background: linear-gradient(135deg,#7c3aed,#4f46e5); color:#fff; border:none; border-radius:10px; padding:10px 22px; font-size:0.95rem; cursor:pointer; font-family:inherit; display:flex; align-items:center; gap:8px;">
          ⭐ أضف تقييمك
        </button>

        <div id="review-form-$orderId" style="display:none; margin-top:18px;">
          <div style="display:flex; flex-direction:column; gap:14px;">
            
            <div class="form-group">
              <label style="display:block; margin-bottom:6px; font-size:0.9rem; opacity:0.85;">الاسم</label>
              <input id="review-name-$orderId" type="text" class="form-control"
                value="$studentName" placeholder="اسمك"
                style="width:100%; box-sizing:border-box;" />
            </div>

            <div class="form-group">
              <label style="display:block; margin-bottom:6px; font-size:0.9rem; opacity:0.85;">الجامعة / التخصص</label>
              <input id="review-university-$orderId" type="text" class="form-control"
                value="$university" placeholder="الجامعة أو التخصص (اختياري)"
                style="width:100%; box-sizing:border-box;" />
            </div>

            <div class="form-group">
              <label style="display:block; margin-bottom:8px; font-size:0.9rem; opacity:0.85;">التقييم</label>
              <div id="stars-$orderId" style="display:flex; flex-direction:row-reverse; justify-content:flex-end; gap:6px; font-size:1.8rem; cursor:pointer; direction:ltr;">
                <span class="star" data-val="5" style="opacity:0.35; transition:opacity 0.15s;">★</span>
                <span class="star" data-val="4" style="opacity:0.35; transition:opacity 0.15s;">★</span>
                <span class="star" data-val="3" style="opacity:0.35; transition:opacity 0.15s;">★</span>
                <span class="star" data-val="2" style="opacity:0.35; transition:opacity 0.15s;">★</span>
                <span class="star" data-val="1" style="opacity:0.35; transition:opacity 0.15s;">★</span>
              </div>
            </div>

            <div class="form-group">
              <label style="display:block; margin-bottom:6px; font-size:0.9rem; opacity:0.85;">تعليقك</label>
              <textarea id="review-text-$orderId" class="form-control" rows="3"
                placeholder="شاركنا تجربتك مع الخدمة..."
                style="width:100%; box-sizing:border-box; resize:vertical; min-height:80px;"></textarea>
            </div>

            <div style="display:flex; gap:10px; justify-content:flex-end; flex-wrap:wrap;">
              <button id="review-cancel-$orderId"
                style="background:rgba(255,255,255,0.08); color:rgba(255,255,255,0.7); border:1px solid rgba(255,255,255,0.15); border-radius:8px; padding:9px 20px; font-size:0.9rem; cursor:pointer; font-family:inherit;">
                إلغاء
              </button>
              <button id="review-submit-$orderId"
                style="background: linear-gradient(135deg,#7c3aed,#4f46e5); color:#fff; border:none; border-radius:8px; padding:9px 22px; font-size:0.9rem; cursor:pointer; font-family:inherit; font-weight:600;">
                إرسال التقييم
              </button>
            </div>

          </div>
        </div>
      </div>
    ''';
  }

  void _setupReviewCard(html.Element card, String orderId, String studentName, String university) {
    int selectedRating = 5; // default

    final reviewBtn   = card.querySelector('#review-btn-$orderId')   as html.ButtonElement?;
    final reviewForm  = card.querySelector('#review-form-$orderId');
    final cancelBtn   = card.querySelector('#review-cancel-$orderId') as html.ButtonElement?;
    final submitBtn   = card.querySelector('#review-submit-$orderId') as html.ButtonElement?;
    final nameInput   = card.querySelector('#review-name-$orderId')   as html.InputElement?;
    final uniInput    = card.querySelector('#review-university-$orderId') as html.InputElement?;
    final textArea    = card.querySelector('#review-text-$orderId')   as html.TextAreaElement?;
    final starsDiv    = card.querySelector('#stars-$orderId');

    // Star interaction
    if (starsDiv != null) {
      final stars = starsDiv.querySelectorAll('.star');

      void highlightStars(int rating) {
        for (final s in stars) {
          final val = int.tryParse(s.getAttribute('data-val') ?? '0') ?? 0;
          s.style.opacity = val <= rating ? '1' : '0.3';
          s.style.color   = val <= rating ? '#fbbf24' : '';
        }
      }

      // Default: show 5 stars selected
      highlightStars(5);

      for (final s in stars) {
        s.onMouseEnter.listen((_) {
          final val = int.tryParse(s.getAttribute('data-val') ?? '0') ?? 0;
          highlightStars(val);
        });
        s.onMouseLeave.listen((_) => highlightStars(selectedRating));
        s.onClick.listen((_) {
          selectedRating = int.tryParse(s.getAttribute('data-val') ?? '5') ?? 5;
          highlightStars(selectedRating);
        });
      }
    }

    // Toggle form visibility
    reviewBtn?.onClick.listen((_) {
      if (reviewForm != null) reviewForm.style.display = 'block';
      reviewBtn.style.display = 'none';
    });

    cancelBtn?.onClick.listen((_) {
      if (reviewForm != null) reviewForm.style.display = 'none';
      reviewBtn?.style.display = '';
    });

    // Submit
    submitBtn?.onClick.listen((_) async {
      final name = nameInput?.value?.trim() ?? '';
      if (name.isEmpty) {
        html.window.alert('الرجاء إدخال اسمك.');
        return;
      }
      final text = textArea?.value?.trim() ?? '';
      if (text.isEmpty) {
        html.window.alert('الرجاء كتابة تعليقك.');
        return;
      }
      final uni  = uniInput?.value?.trim() ?? university;

      submitBtn.disabled = true;
      submitBtn.text = 'جاري الإرسال...';

      _onReviewSubmit?.call(orderId, name, uni, selectedRating, text);
    });
  }

  /// Call this after a successful review submission for a given order.
  void markReviewSent(String orderId) {
    final section = html.document.getElementById('review-section-$orderId');
    if (section != null) {
      section.setInnerHtml(
        '<p style="color:#4ade80; font-weight:600; margin-top:12px;">✓ شكراً! تم إرسال تقييمك بنجاح.</p>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
    }
  }

  void showError(String error) {
    html.window.alert('عذراً، حدث خطأ: $error');
  }
}

