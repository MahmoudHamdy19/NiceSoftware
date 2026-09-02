import 'dart:html' as html;
import '../controllers/form_controller.dart';
import '../controllers/cms_controller.dart';
import '../services/supabase_service.dart';
import '../views/form_view.dart';
import '../repositories/service_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/review_repository.dart';
import '../views/cms_view.dart';
import '../controllers/my_orders_controller.dart';
import '../views/my_orders_view.dart';
import '../repositories/request_repository.dart';
class SpaRouter {
  final html.Element _appRoot;
  final SupabaseService _supabaseService;
  late final CMSController _cmsController;

  SpaRouter(this._appRoot, this._supabaseService) {
    _cmsController = CMSController(
      serviceRepository: ServiceRepository(_supabaseService.client),
      newsRepository: NewsRepository(_supabaseService.client),
      projectRepository: ProjectRepository(_supabaseService.client),
      reviewRepository: ReviewRepository(_supabaseService.client),
      view: CmsView(),
    );

    // Listen to back/forward buttons
    html.window.onPopState.listen((_) => _handleRoute());

    // Intercept clicks on links
    html.document.body?.onClick.listen(_handleLinkClick);

    // Setup mobile menu
    _setupMobileMenu();

    // Load initial route
    _handleRoute();
  }

  void _setupMobileMenu() {
    final toggleBtn = html.document.querySelector('.menu-toggle');
    final nav = html.document.querySelector('header nav');
    
    if (toggleBtn != null && nav != null) {
      toggleBtn.onClick.listen((_) {
        nav.classes.toggle('active');
        if (nav.classes.contains('active')) {
          toggleBtn.innerHtml = '✖';
          html.document.body?.style.overflow = 'hidden'; // Prevent scrolling when menu is open
        } else {
          toggleBtn.innerHtml = '☰';
          html.document.body?.style.overflow = '';
        }
      });
    }
  }

  void _handleLinkClick(html.MouseEvent event) {
    // Find if the clicked element or its parent is an anchor tag
    html.Element? target = event.target as html.Element?;
    while (target != null && target is! html.AnchorElement) {
      target = target.parent;
    }

    if (target is html.AnchorElement) {
      final href = target.getAttribute('href');

      // If it's a relative link (starts with / or is just a word, and not an external link or hash)
      if (href != null && href.startsWith('/') && !href.startsWith('//')) {
        event.preventDefault();

        // Push state and trigger route manually
        html.window.history.pushState(null, '', href);
        _handleRoute();

        // If on mobile, close the mobile menu if it's open
        final nav = html.document.querySelector('header nav');
        final toggleBtn = html.document.querySelector('.menu-toggle');
        if (nav != null && nav.classes.contains('active')) {
          nav.classes.remove('active');
          if (toggleBtn != null) toggleBtn.innerHtml = '☰';
          html.document.body?.style.overflow = '';
        }
      }
    }
  }

  Future<void> _handleRoute() async {
    String path = html.window.location.pathname ?? '/';

    // Strip trailing slash except for root
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // Default to home
    if (path == '/' || path.isEmpty) {
      path = '/home';
    }

    // Extract page name (e.g., /services -> services)
    String pageName = path.replaceFirst('/', '');

    // Simple sanitization for file loading
    if (pageName.contains('..') || pageName.contains('/')) {
      pageName = 'home';
    }

    try {
      final response = await html.HttpRequest.getString('pages/$pageName.html');

      _appRoot.setInnerHtml(
        response,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );

      _initializeForms();

      // Load dynamic CMS data based on page
      if (pageName == 'services' || pageName == 'home') {
        await _cmsController.loadServices();
      } else if (pageName == 'news') {
        await _cmsController.loadNews();
      } else if (pageName == 'projects') {
        await _cmsController.loadProjects();
      } else if (pageName == 'reviews') {
        await _cmsController.loadReviews();
      } else if (pageName == 'my_orders') {
        final myOrdersView = MyOrdersView();
        final requestRepo = RequestRepository(_supabaseService.client);
        final reviewRepo  = ReviewRepository(_supabaseService.client);
        MyOrdersController(myOrdersView, requestRepo, reviewRepo);
      }

      html.window.scrollTo(0, 0);
      _updateNavLinks(path);
    } catch (e) {
      _appRoot.setInnerHtml(
        '<section style="text-align: center; padding: 100px 20px;"><h2>الصفحة غير موجودة (404)</h2><p>عذراً، الرابط غير صحيح.</p></section>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
    }
  }

  void _initializeForms() {
    final forms = html.document.querySelectorAll('#supabase-form');
    for (final element in forms) {
      final formElement = element as html.FormElement;
      final view = FormView(formElement);
      FormController(view, _supabaseService);
    }
  }

  void _updateNavLinks(String currentPath) {
    final links = html.document.querySelectorAll('nav a');
    for (final link in links) {
      link.style.color = '';
      final href = (link as html.AnchorElement).getAttribute('href');
      // If href matches current path (or if it's '/' and current path is '/home')
      if (href == currentPath || (href == '/' && currentPath == '/home')) {
        link.style.color = 'var(--primary-color)';
      }
    }
  }
}
