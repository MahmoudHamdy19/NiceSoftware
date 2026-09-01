class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String linkUrl;
  final String colorVar;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.linkUrl,
    required this.colorVar,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      linkUrl: json['link_url']?.toString() ?? '',
      colorVar: json['color_var']?.toString() ?? '',
    );
  }
}
