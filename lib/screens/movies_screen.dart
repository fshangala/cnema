import 'package:cnema/models/movie_model.dart';
import 'package:cnema/scrapers/fzmovies.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final fzmovies = Fzmovies();
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);

  var page = 1;

  Future<void> downloadMovie(String downloadLink, String name) async {
    final savePath =
        "${(await getApplicationDocumentsDirectory()).path}/$name.mp4";
    await Dio().download(
      downloadLink,
      savePath,
      onReceiveProgress: (count, total) {
        downloadProgress.value = count / total;
      },
    );
    downloadProgress.value = 0.0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloaded $name"),
        ),
      );
    });
  }

  showMovieDialog(MovieModel movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Movie Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  "${Fzmovies.baseUrl}${movie.image}",
                  errorBuilder: (context, error, trace) {
                    return Image.asset("assets/movie.png");
                  },
                ),
                Text(movie.title),
                Text(movie.year.toString()),
                Text(movie.quality!),
                Text(movie.description ?? ""),
                FutureBuilder(
                  future: fzmovies.getDownloadLinks(movie),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        spacing: 8.0,
                        children: snapshot.data!.map((link) {
                          return ListTile(
                            title: Text("Download"),
                            subtitle: Text(link),
                            trailing: Icon(Icons.download),
                            onTap: () async {
                              await downloadMovie(link, movie.title);
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 8.0,
          children: [
            ValueListenableBuilder(
              valueListenable: downloadProgress,
              builder: (context, value, child) {
                if (value == 0.0) return const SizedBox();
                return ListTile(
                  leading: Text("${(value * 100).floor()} %"),
                  title: Text("Download Progress"),
                  subtitle: LinearProgressIndicator(
                    value: value,
                  ),
                );
              },
            ),
            FutureBuilder(
              future: fzmovies.getMovies(page: page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Image.network(
                              alignment: Alignment.center,
                              "${Fzmovies.baseUrl}${snapshot.data![index].image}",
                              errorBuilder: (context, error, trace) {
                                return Image.asset("assets/movie.png");
                              },
                            ),
                            title: Text(snapshot.data![index].title),
                            subtitle: snapshot.data![index].description == null
                                ? null
                                : Text(
                                    snapshot.data![index].description!,
                                  ),
                            onTap: () {
                              showMovieDialog(snapshot.data![index]);
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  Logger().e(snapshot.error, stackTrace: snapshot.stackTrace);
                  return Text(snapshot.error.toString());
                } else {
                  return Text("Nothing to show!");
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
