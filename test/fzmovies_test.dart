import 'package:cnema/scrapers/fzmovies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  test(
    "Test FZmovies Scraper",
    () async {
      final fzmovies = Fzmovies();
      final movies = await fzmovies.getMovies();
      Logger().i(movies.toString());
    },
  );

  test("Download links test", () async {
    final fzmovies = Fzmovies();
    final movies = await fzmovies.getMovies();
    final downloadLinks = await fzmovies.getDownloadLinks(movies[0]);
    Logger().i(downloadLinks);
  });
}
