import 'package:cnema/screens/home_screen.dart';
import 'package:cnema/screens/movies_screen.dart';
import 'package:cnema/screens/series_screen.dart';
import 'package:cnema/screens/series_single_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/movies':
            return MaterialPageRoute(builder: (_) => const MoviesScreen());
          case '/tvseries':
            return MaterialPageRoute(builder: (_) => const SeriesScreen());
          case '/tvseries/single':
            return MaterialPageRoute(
              builder: (context) {
                final args = settings.arguments as Map<String, dynamic>;
                return SeriesSingleScreen(
                  show: args['show'],
                );
              },
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
