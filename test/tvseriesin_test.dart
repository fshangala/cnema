import 'package:cnema/scrapers/tvseries.in.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  test(
    "Test TVSeriesIn Scraper",
    () async {
      final tvseriesin = TvSeriesIn();
      final tvseries = await tvseriesin.getShows();
      Logger().i(tvseries.toString());
    },
  );
}
