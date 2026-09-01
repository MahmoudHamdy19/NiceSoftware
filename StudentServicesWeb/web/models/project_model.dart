class ProjectModel {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String linkUrl;

  ProjectModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.linkUrl,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      linkUrl: json['link_url']?.toString() ?? '',
    );
  }
}
