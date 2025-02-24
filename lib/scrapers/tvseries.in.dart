import 'package:cnema/models/episode_model.dart';
import 'package:cnema/models/season_model.dart';
import 'package:cnema/models/series_model.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TvSeriesIn {
  static final String baseUrl = "https://tvseries.in";

  Future<List<SeriesModel>> getShows({int page = 1}) async {
    final response = await http.Client().get(
      Uri.parse("${TvSeriesIn.baseUrl}/genre.php?pg=$page"),
    );
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final serieRows = document.querySelectorAll("div.mainbox3 table tr img");

      final series = serieRows.map((serie) {
        serie = serie.parent!.parent!.parent!.parent!;
        final link = serie.children[0].querySelector("a")?.attributes["href"];
        final image = serie.children[0].querySelector("img")?.attributes["src"];
        final title = serie.children[1].querySelector("span a")?.text;
        final description =
            serie.children[1].querySelectorAll("span small")[2].text;

        return SeriesModel(
          title: title!,
          link: "$baseUrl/$link",
          image: "$baseUrl/$image",
          description: description,
        );
      }).toList();

      return series;
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }

  Future<List<SeasonModel>> getSeasons({required String showLink}) async {
    final response = await http.Client().get(Uri.parse(showLink));
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final seasonRows = document.querySelectorAll(
        "div[itemprop=containsSeason] div.mainbox2 a",
      );

      final seasons = seasonRows.map((season) {
        final link = season.attributes["href"];
        final name = season.text;

        return SeasonModel(
          name: name,
          link: "$baseUrl/$link",
        );
      }).toList();

      return seasons;
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }

  Future<List<EpisodeModel>> getEpisodes({required String seasonLink}) async {
    final response = await http.Client().get(Uri.parse(seasonLink));
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final episodeRows = document.querySelectorAll(
        "div.mainbox table tr",
      );

      final episodes = episodeRows.map((episode) {
        final link =
            episode.children[1].querySelector("span a")?.attributes["href"];
        final title =
            episode.children[1].querySelectorAll("span small")[0].text;

        return EpisodeModel(
          title: title,
          link: "$baseUrl/$link",
        );
      }).toList();

      return episodes;
    } else {
      throw Exception("Response error: ${response.statusCode}");
    }
  }

  Future<List<String>> getEpisodeDownloadLinks(
      {required String episodeLink}) async {
    final client = http.Client();
    String? cookies;

    var response = await client.get(Uri.parse(episodeLink));
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var downloadLinksPage = document.getElementById("downloadlink");
      cookies = response.headers["set-cookie"] ?? cookies;
      Logger().i(
          "downloadlink:${downloadLinksPage?.outerHtml}\n\nCookies:$cookies");

      if (downloadLinksPage != null) {
        Logger()
            .d("${TvSeriesIn.baseUrl}/${downloadLinksPage.attributes['href']}");
        response = await client.get(
          Uri.parse(
              "${TvSeriesIn.baseUrl}/${downloadLinksPage.attributes['href']}"),
          headers: {"Cookie": cookies ?? ""},
        );
        if (response.statusCode == 200) {
          document = parser.parse(response.body);
          var downloadLinks =
              document.querySelectorAll("input[name='download1']");
          cookies = response.headers["set-cookie"] ?? cookies;
          Logger()
              .i("input[name='download1']:$downloadLinks\n\nCookies:$cookies");
          return downloadLinks
              .map(
                (downloadLink) => downloadLink.attributes["value"] as String,
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
  }
}
