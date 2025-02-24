import 'package:cnema/models/series_model.dart';
import 'package:cnema/scrapers/tvseries.in.dart';
import 'package:flutter/material.dart';

class SeriesSingleScreen extends StatefulWidget {
  final SeriesModel show;
  const SeriesSingleScreen({super.key, required this.show});

  @override
  State<SeriesSingleScreen> createState() => _SeriesSingleScreenState();
}

class _SeriesSingleScreenState extends State<SeriesSingleScreen> {
  final tvSeriesIn = TvSeriesIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.show.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.network(widget.show.image, height: 200),
            Text(widget.show.description),
            FutureBuilder(
              future: tvSeriesIn.getSeasons(showLink: widget.show.link),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.map<Widget>((season) {
                      return ListTile(
                        title: Text(season.name),
                        onTap: () {
                          showBottomSheet(
                            enableDrag: true,
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text("Close"),
                                    trailing: Icon(Icons.close),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FutureBuilder(
                                      future: tvSeriesIn.getEpisodes(
                                          seasonLink: season.link),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasData) {
                                          return Expanded(
                                            child: ListView(
                                              children: snapshot.data!
                                                  .map<Widget>((episode) {
                                                return ListTile(
                                                  title: Text(episode.title),
                                                  onTap: () {},
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              snapshot.error.toString());
                                        } else {
                                          return const Text("Nothing to show!");
                                        }
                                      }),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return const Text("Nothing to show!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
