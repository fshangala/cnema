import 'package:cnema/screens/home_screen.dart';
import 'package:cnema/screens/movies_screen.dart';
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
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        listTileTheme: ListTileTheme.of(context).copyWith(
          textColor: Colors.white,
        ),
        dialogTheme: DialogTheme.of(context).copyWith(
          contentTextStyle: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/movies':
            return MaterialPageRoute(builder: (_) => const MoviesScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
