class MovieModel {
  String title;
  int? year;
  String link;
  String image;
  String? quality;
  String? description;

  MovieModel({
    required this.title,
    this.year,
    required this.link,
    required this.image,
    this.quality,
    this.description,
  });
}
