import 'package:cnema/models/series_model.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

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
}
