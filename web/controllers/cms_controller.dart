import '../repositories/service_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/review_repository.dart';
import '../views/cms_view.dart';

class CMSController {
  final ServiceRepository _serviceRepository;
  final NewsRepository _newsRepository;
  final ProjectRepository _projectRepository;
  final ReviewRepository _reviewRepository;
  final CmsView _view;

  CMSController({
    required ServiceRepository serviceRepository,
    required NewsRepository newsRepository,
    required ProjectRepository projectRepository,
    required ReviewRepository reviewRepository,
    required CmsView view,
  })  : _serviceRepository = serviceRepository,
        _newsRepository = newsRepository,
        _projectRepository = projectRepository,
        _reviewRepository = reviewRepository,
        _view = view;

  Future<void> loadServices() async {
    _view.showLoading('cms-services-container', 'جاري تحميل الخدمات...');
    try {
      final services = await _serviceRepository.getAllServices();
      _view.renderServices(services);
    } catch (e) {
      _view.showError('cms-services-container', 'حدث خطأ في تحميل الخدمات.');
    }
  }

  Future<void> loadNews() async {
    _view.showLoading('cms-news-container', 'جاري تحميل الأخبار...');
    try {
      final news = await _newsRepository.getAllNews();
      _view.renderNews(news);
    } catch (e) {
      _view.showError('cms-news-container', 'حدث خطأ في تحميل الأخبار.');
    }
  }

  Future<void> loadProjects() async {
    _view.showLoading('cms-projects-container', 'جاري تحميل المشاريع...');
    try {
      final projects = await _projectRepository.getAllProjects();
      _view.renderProjects(projects);
    } catch (e) {
      _view.showError('cms-projects-container', 'حدث خطأ في تحميل المشاريع.');
    }
  }

  Future<void> loadReviews() async {
    _view.showLoading('cms-reviews-container', 'جاري تحميل الآراء...');
    try {
      final reviews = await _reviewRepository.getAllReviews();
      _view.renderReviews(reviews);
    } catch (e) {
      _view.showError('cms-reviews-container', 'حدث خطأ في تحميل الآراء.');
    }
  }
}
