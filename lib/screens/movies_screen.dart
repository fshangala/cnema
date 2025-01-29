import 'package:cnema/models/movie_model.dart';
import 'package:cnema/scrapers/fzmovies.dart';
import 'package:flutter/material.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final fzmovies = Fzmovies();

  showMovieDialog(MovieModel movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Movie Details'),
          content: Column(
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
            ],
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
            FutureBuilder(
              future: fzmovies.getMovies(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
