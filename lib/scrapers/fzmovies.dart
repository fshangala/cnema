import 'package:cnema/models/movie_model.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Fzmovies {
  static final String baseUrl = "https://fzmovies.host";

  Future<List<MovieModel>> getMovies({
    int page = 1,
  }) async {
    final response = await http.Client().get(
      Uri.parse("${Fzmovies.baseUrl}/movieslist.php?catID=2&by=date&pg=$page"),
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
        var quality = "";
        var description = "";
        if (detailMarkup!.children.length > 4) {
          quality = detailMarkup.children[2].text;
          description = detailMarkup.children[4].text;
        } else {
          description = detailMarkup.children[3].text;
        }

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

  Future<List<String>> getDownloadLinks(MovieModel movie) async {
    final client = http.Client();
    String? cookies;

    var response = await client.get(
      Uri.parse("${Fzmovies.baseUrl}/${movie.link}"),
    );

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var downloadLinksPage = document.querySelector("a#downloadoptionslink2");
      cookies = response.headers["set-cookie"];
      Logger().i(
          "a#downloadoptionslink2:${downloadLinksPage?.outerHtml}\n\nCookies:$cookies");

      if (downloadLinksPage != null) {
        Logger()
            .d("${Fzmovies.baseUrl}/${downloadLinksPage.attributes['href']}");
        response = await client.get(
          Uri.parse(
              "${Fzmovies.baseUrl}/${downloadLinksPage.attributes['href']}"),
          headers: {"Cookie": cookies ?? ""},
        );
        if (response.statusCode == 200) {
          document = parser.parse(response.body);
          downloadLinksPage = document.getElementById("downloadlink");
          cookies = response.headers["set-cookie"] ?? cookies;
          Logger().i(
              "downloadlink:${downloadLinksPage?.outerHtml}\n\nCookies:$cookies");

          if (downloadLinksPage != null) {
            Logger().d(
                "${Fzmovies.baseUrl}/${downloadLinksPage.attributes['href']}");
            response = await client.get(
              Uri.parse(
                  "${Fzmovies.baseUrl}/${downloadLinksPage.attributes['href']}"),
              headers: {"Cookie": cookies ?? ""},
            );
            if (response.statusCode == 200) {
              document = parser.parse(response.body);
              var downloadLinks =
                  document.querySelectorAll("input[name='download1']");
              cookies = response.headers["set-cookie"] ?? cookies;
              Logger().i(
                  "input[name='download1']:$downloadLinks\n\nCookies:$cookies");
              return downloadLinks
                  .map(
                    (downloadLink) =>
                        downloadLink.attributes["value"] as String,
                  )
                  .toList();
            } else {
              throw Exception("Response error: ${response.statusCode}");
            }
          } else {
            throw Exception("Response error: Download links page not found!");
          }
        } else {
          throw Exception("Response error: ${response.statusCode}");
        }
      } else {
        throw Exception("Response error: Download links page not found!");
      }
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }
}
