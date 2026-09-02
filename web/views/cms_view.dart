import 'dart:html' as html;
import '../models/service_model.dart';
import '../models/project_model.dart';
import '../models/news_model.dart';
import '../models/review_model.dart';

class CmsView {
  void showLoading(String containerId, String text) {
    final container = html.document.getElementById(containerId);
    if (container == null) return;
    container.innerHtml =
        '<div class="loading-container"><div class="loader"></div><p style="margin-top: 15px; color: var(--text-color);">$text</p></div>';
  }

  void showError(String containerId, String text) {
    final container = html.document.getElementById(containerId);
    if (container == null) return;
    container.innerHtml =
        '<div style="text-align: center; width: 100%; grid-column: 1 / -1; color: red;"><p>$text</p></div>';
  }

  void renderServices(List<ServiceModel> services) {
    final container = html.document.getElementById('cms-services-container');
    if (container == null) return;

    if (services.isEmpty) {
      container.innerHtml =
          '<div style="text-align: center; width: 100%; grid-column: 1 / -1;"><p>لا توجد خدمات متاحة حالياً.</p></div>';
      return;
    }

    container.innerHtml = '';

    for (var service in services) {
      final div = html.Element.div()
        ..className = 'glass-card'
        ..style.display = 'flex'
        ..style.flexDirection = 'column'
        ..setInnerHtml('''
          <h3 style="margin-bottom: 15px; color: var(${service.colorVar}); font-size: 1.5rem;">${service.title}</h3>
          <p style="flex-grow: 1; margin-bottom: 20px;">${service.description}</p>
          <a href="${service.linkUrl}" class="btn-primary" style="text-align: center; width: 100%;">اطلب الآن</a>
        ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      container.children.add(div);
    }
  }

  void renderNews(List<NewsModel> newsList) {
    final container = html.document.getElementById('cms-news-container');
    if (container == null) return;

    if (newsList.isEmpty) {
      container.innerHtml =
          '<div style="text-align: center; width: 100%;"><p>لا توجد أخبار متاحة حالياً.</p></div>';
      return;
    }

    container.innerHtml = '';

    for (var item in newsList) {
      final String dateStr = item.createdAt?.toString().split('T').first ?? '';

      final article = html.Element.article()
        ..className = 'glass-card'
        ..setInnerHtml('''
          <span style="color: var(--primary-color); font-weight: 700; font-size: 0.9rem;">$dateStr</span>
          <h3 style="margin: 10px 0; font-size: 1.8rem;">${item.title}</h3>
          <p style="margin-bottom: 20px;">${item.content}</p>
        ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      container.children.add(article);
    }
  }

  void renderProjects(List<ProjectModel> projectsList) {
    final container = html.document.getElementById('cms-projects-container');
    if (container == null) return;

    if (projectsList.isEmpty) {
      container.innerHtml =
          '<div style="text-align: center; width: 100%; grid-column: 1 / -1;"><p>لا توجد مشاريع متاحة حالياً.</p></div>';
      return;
    }

    container.innerHtml = '';

    for (var item in projectsList) {
      final categories = item.category
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      String badgesHtml = '';
      final colors = ['#a5b4fc', '#f9a8d4', '#7dd3fc', '#86efac'];
      final bgColors = [
        'rgba(99,102,241,0.2)',
        'rgba(236,72,153,0.2)',
        'rgba(14,165,233,0.2)',
        'rgba(34,197,94,0.2)'
      ];

      for (int i = 0; i < categories.length; i++) {
        final c = colors[i % colors.length];
        final bg = bgColors[i % bgColors.length];
        badgesHtml +=
            '<span style="background: $bg; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem; color: $c; margin-left: 5px;">${categories[i]}</span>';
      }

      final div = html.Element.div()
        ..className = 'glass-card'
        ..setInnerHtml('''
          <div class="project-img" style="min-height: 200px; border-radius: 8px; margin-bottom: 15px; background-image: url('${item.imageUrl}'); background-size: cover; background-position: center; display: flex; align-items: center; justify-content: center; background-color: rgba(0,0,0,0.3);">
              ${item.imageUrl.isEmpty ? '<span>[ صورة المشروع ]</span>' : ''}
          </div>
          <h3 style="margin-bottom: 10px; font-size: 1.4rem;">${item.title}</h3>
          ${item.linkUrl.isNotEmpty ? '<p style="margin-bottom: 15px; font-size: 0.95rem;">${item.linkUrl}</p>' : ''}
          <div style="display: flex; gap: 10px; flex-wrap: wrap;">
              $badgesHtml
          </div>
        ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      container.children.add(div);
    }
  }

  void renderReviews(List<ReviewModel> reviewsList) {
    final container = html.document.getElementById('cms-reviews-container');
    if (container == null) return;

    if (reviewsList.isEmpty) {
      container.innerHtml =
          '<div style="text-align: center; width: 100%; grid-column: 1 / -1;"><p>لا توجد آراء متاحة حالياً.</p></div>';
      return;
    }

    container.innerHtml = '';

    for (var item in reviewsList) {
      final stars = '\u2605' * item.rating + '\u2606' * (5 - item.rating);

      final div = html.Element.div()
        ..className = 'glass-card'
        ..setInnerHtml('''
          <div class="stars" style="color: #fbbf24; font-size: 1.5rem; margin-bottom: 10px;">$stars</div>
          <p style="font-style: italic; margin-bottom: 20px;">"${item.reviewText}"</p>
          <div>
              <h4 style="font-size: 1.1rem; margin:0;">${item.customerName}</h4>
              <span style="font-size: 0.8rem; color: #94a3b8;">${item.customerMajor}</span>
          </div>
        ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

      container.children.add(div);
    }
  }
}
