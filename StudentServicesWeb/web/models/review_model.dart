class ReviewModel {
  final String id;
  final String customerName;
  final String customerMajor;
  final int rating;
  final String reviewText;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.customerMajor,
    required this.rating,
    required this.reviewText,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      customerName: json['student_name']?.toString() ?? '',
      customerMajor: json['university']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      reviewText: json['review_text']?.toString() ?? '',
    );
  }
}
