import '../views/my_orders_view.dart';
import '../repositories/request_repository.dart';
import '../repositories/review_repository.dart';

class MyOrdersController {
  final MyOrdersView view;
  final RequestRepository requestRepository;
  final ReviewRepository reviewRepository;

  MyOrdersController(this.view, this.requestRepository, this.reviewRepository) {
    view.onSearchSubmit(_handleSearch);
    view.onReviewSubmit(_handleReviewSubmit);
  }

  Future<void> _handleSearch(String phone) async {
    view.setLoading(true);
    try {
      final allRequests = await requestRepository.getAllRequests();
      
      final userOrders = allRequests.where((req) {
        final reqPhone = req['input_phone'] ?? req['input-phone'];
        return reqPhone == phone;
      }).toList();

      view.renderOrders(userOrders);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.setLoading(false);
    }
  }

  Future<void> _handleReviewSubmit(
    String orderId,
    String studentName,
    String university,
    int rating,
    String reviewText,
  ) async {
    try {
      await reviewRepository.addReview({
        'student_name': studentName,
        'university': university.isEmpty ? null : university,
        'rating': rating,
        'review_text': reviewText,
      });
      view.markReviewSent(orderId);
    } catch (e) {
      view.showError(e.toString());
    }
  }
}
