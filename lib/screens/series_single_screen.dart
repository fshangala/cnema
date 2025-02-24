import 'package:cnema/models/series_model.dart';
import 'package:flutter/material.dart';

class SeriesSingleScreen extends StatefulWidget {
  final SeriesModel show;
  const SeriesSingleScreen({super.key, required this.show});

  @override
  State<SeriesSingleScreen> createState() => _SeriesSingleScreenState();
}

class _SeriesSingleScreenState extends State<SeriesSingleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.show.title),
      ),
      body: Center(
        child: Text(widget.show.description),
      ),
    );
  }
}
