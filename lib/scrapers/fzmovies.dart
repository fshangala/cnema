import 'package:cnema/models/movie_model.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class Fzmovies {
  static final String baseUrl = "https://fzmovies.host";

  Future<List<MovieModel>> getMovies() async {
    final response = await http.Client().get(
      Uri.parse("${Fzmovies.baseUrl}/movieslist.php?catID=2&by=date"),
    );
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final movieRows = document.querySelectorAll("div.mainbox table tr");

      final movies = movieRows.map((movie) {
        final link = movie.children[0].querySelector("a")?.attributes["href"];
        final image = movie.children[0].querySelector("img")?.attributes["src"];

        final detailMarkup = movie.children[1].querySelector("span");
        final title = detailMarkup?.children[0].text;
        final year = detailMarkup?.children[1].text;
        final quality = detailMarkup?.children[2].text;
        final description = detailMarkup?.children[4].text;

        return MovieModel(
          title: title!,
          year: year == null ? null : int.parse(year.substring(1, 5)),
          link: link!,
          image: image!,
          quality: quality,
          description: description,
        );
      }).toList();

      return movies;
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }

  getDownloadLinks(MovieModel movie) async {
    final response = await http.Client().get(
      Uri.parse("${Fzmovies.baseUrl}${movie.link}"),
    );
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final downloadLinks = document.querySelectorAll("div.downloadtable a");

      return downloadLinks.map((link) {
        return link.attributes["href"];
      }).toList();
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }
}
