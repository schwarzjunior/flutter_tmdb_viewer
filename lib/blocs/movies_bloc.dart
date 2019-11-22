import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/api.dart';
import 'package:tmdb_viewer/api/tmdb_api.dart';
import 'package:tmdb_viewer/models/movie.dart';

class MoviesBloc extends BlocBase {
  Api api;
  ApiSearch apiSearch;

  List<Movie> movies;

  final StreamController<List<Movie>> _moviesController = StreamController<List<Movie>>();
  final StreamController<String> _searchController = StreamController<String>();

  Stream get outMovies => _moviesController.stream;

  MoviesBloc() {
    api = Api();
    apiSearch = ApiSearch();
  }

  bool get hasNextPage => apiSearch.hasNextPage;

  void search(String query) async {
    // Cleaning last search.
    _moviesController.sink.add(null);
    movies = await apiSearch.movies(query: query);
    _moviesController.sink.add(movies);
  }

  void getNextPage() async {
    movies += await apiSearch.movies(nextPage: true);
    _moviesController.sink.add(movies);
  }

  @override
  void dispose() {
    _moviesController.close();
    _searchController.close();
    super.dispose();
  }
}
