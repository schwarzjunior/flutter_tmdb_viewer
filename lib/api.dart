import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/models/movie_details.dart';
import 'package:tmdb_viewer/models/movie_search_suggestion.dart';

const apiKey = 'ffea4ca1099c6f945cfe912e08056be2';
const apiImageUrlPrefix = 'https://image.tmdb.org/t/p/w500';
const youtubeVideoUrlPrefix = 'https://www.youtube.com/watch?v=';

class Api {
  static const bool _include_adult = true;

  String _search;
  int _nextPage;
  int _totalPages;

  bool get hasNextPage => _totalPages != null ? _totalPages > (_nextPage - 1) : false;

  ///
  Future<List<Movie>> search(String search) async {
    _search = search;
    _nextPage = 1;

    http.Response response = await http.get('https://api.themoviedb.org/3/search/movie'
        '?api_key=$apiKey'
        '&query=$_search'
        '&page=1'
        '&include_adult=$_include_adult');

    return decodeMovie(response);
  }

  Future<List<Movie>> nextPage() async {
    http.Response response = await http.get('https://api.themoviedb.org/3/search/movie'
        '?api_key=$apiKey'
        '&query=$_search'
        '&page=$_nextPage'
        '&include_adult=$_include_adult');

    return decodeMovie(response);
  }

  Future<MovieDetails> getDetails(Movie movie) async {
    http.Response response = await http.get('https://api.themoviedb.org/3/movie/'
        '${movie.idString}'
        '?api_key=$apiKey'
        '&append_to_response=videos');

    return decodeMovieDetails(movie, response);
  }

  Future<List<MovieSearchSuggestion>> suggestions(String search) async {
    http.Response response = await http.get('https://api.themoviedb.org/3/search/multi'
        '?api_key=$apiKey'
        '&query=$search'
        '&page=1'
        '&include_adult=$_include_adult');

    return decodeSuggestion(response);
  }

  List<MovieSearchSuggestion> decodeSuggestion(http.Response response) {
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      List<MovieSearchSuggestion> searchSuggestions =
          decoded['results'].where((ms) => ms['media_type'] == 'movie').toList().map<MovieSearchSuggestion>((ms) {
        return MovieSearchSuggestion.fromJson(ms);
      }).toList();
      /*List<MovieSearchSuggestion> searchSuggestions =
          decoded['results'].map<MovieSearchSuggestion>((ms) {
        return MovieSearchSuggestion.fromJson(ms);
      }).toList();
      print(searchSuggestions.where((ms) => ms.mediaType == 'movie'));
      return searchSuggestions.where((ms) => ms.mediaType == 'movie').toList();*/
      return searchSuggestions;
    } else {
      if (response.statusCode == 401)
        throw Exception('TMDb fail! Invalid API key: You must be granted a valid key.');
      else if (response.statusCode == 404)
        throw Exception('TMDb fail! The resource you requested could not be found.');
      else
        throw Exception('Failed to load search suggestions.');
    }
  }

  MovieDetails decodeMovieDetails(Movie movie, http.Response response) {
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      MovieDetails details = MovieDetails.fromJson(movie, decoded);
      return details;
    } else {
      if (response.statusCode == 401)
        throw Exception('TMDb fail! Invalid API key: You must be granted a valid key.');
      else if (response.statusCode == 404)
        throw Exception('TMDb fail! The resource you requested could not be found.');
      else
        throw Exception('Failed to load movies details.');
    }
  }

  List<Movie> decodeMovie(http.Response response) {
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      _nextPage = decoded['page'] + 1;
      _totalPages = decoded['total_pages'];
      List<Movie> movies = decoded['results'].map<Movie>((m) {
        return Movie.fromJson(m);
      }).toList();
      return movies;
    } else {
      if (response.statusCode == 401)
        throw Exception('TMDb fail! Invalid API key: You must be granted a valid key.');
      else if (response.statusCode == 404)
        throw Exception('TMDb fail! The resource you requested could not be found.');
      else
        throw Exception('Failed to load movies.');
    }
  }

  static String buildImageUrl(String url) {
    return (url == null) ? null : '$apiImageUrlPrefix$url';
  }
}
