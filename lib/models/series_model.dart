class SeriesModel {
  final String title;
  final String image;
  final String description;
  final String link;

  SeriesModel({
    required this.title,
    required this.image,
    required this.description,
    required this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
      'description': description,
      'link': link,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
