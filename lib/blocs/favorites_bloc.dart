import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdb_viewer/models/movie.dart';

class FavoritesBloc extends BlocBase {
  static const String _favPrefsKey = 'favorites';

  Map<String, Movie> _favorites = {};

  final _favController = BehaviorSubject<Map<String, Movie>>.seeded({});

  Stream<Map<String, Movie>> get outFav => _favController.stream;

  FavoritesBloc() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getKeys().contains(_favPrefsKey)) {
        _favorites = json.decode(prefs.getString(_favPrefsKey)).map((k, v) {
          return MapEntry(k, Movie.fromJson(v));
        }).cast<String, Movie>();

        _favController.sink.add(_favorites);
      }
    });
  }

  void toggleFavorite(Movie movie) {
    if (_favorites.containsKey(movie.idString)) {
      _favorites.remove(movie.idString);
    } else {
      _favorites[movie.idString] = movie;
    }

    _favController.sink.add(_favorites);
    _saveFav();
  }

  void _saveFav() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_favPrefsKey, json.encode(_favorites));
    });
  }

  @override
  void dispose() {
    _favController.close();
    super.dispose();
  }
}
