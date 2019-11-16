import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/api.dart';
import 'package:tmdb_viewer/models/movie.dart';

class MoviesBloc extends BlocBase {
  Api api;

  List<Movie> movies;

  final StreamController<List<Movie>> _moviesController = StreamController<List<Movie>>();
  final StreamController<String> _searchController = StreamController<String>();

  Stream get outMovies => _moviesController.stream;

  Sink get inSearch => _searchController.sink;

  MoviesBloc() {
    api = Api();
    _searchController.stream.listen(_search);
  }

  bool get hasNextPage => api.hasNextPage;

  void _search(String search) async {
    if (search != null) {
      // nova pesquisa.
      movies = [];
      _moviesController.sink.add(movies);
      movies = await api.search(search);
    } else {
      // obtem a proxima page da pesquisa.
      movies += await api.nextPage();
    }

    _moviesController.sink.add(movies);
  }

  @override
  void dispose() {
    _moviesController.close();
    _searchController.close();
    super.dispose();
  }
}
