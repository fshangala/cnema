import 'package:cnema/scrapers/tvseries.in.dart';
import 'package:flutter/material.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final tvseriesin = TvSeriesIn();

  var page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Series Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder(
              future: tvseriesin.getShows(page: page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final show = snapshot.data![index];
                        return ListTile(
                          leading: Image.network(show.image),
                          title: Text(show.title),
                          subtitle: Text(show.description),
                          onTap: () {},
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return const Text("Nothing to show!");
                }
              },
            ),
            Row(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      page--;
                      if (page < 1) page = 1;
                    });
                  },
                  label: Text("Previous"),
                  icon: Icon(Icons.chevron_left),
                ),
                Text("Page $page"),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      page++;
                    });
                  },
                  label: const Text('Next'),
                  icon: Icon(Icons.chevron_right),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
