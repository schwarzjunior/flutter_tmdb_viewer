import 'dart:convert';

import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/models/movie_details.dart';
import 'package:tmdb_viewer/models/movie_search_suggestion.dart';
import 'package:http/http.dart' as http;

class ApiFunctions {
  static const apiImageUrlPrefix = 'https://image.tmdb.org/t/p/w500';
  static const apiVideoUrlPrefix = 'https://www.youtube.com/watch?v=';

  static String buildImageUrl(String uri) => (uri == null) ? null : '$apiImageUrlPrefix$uri';

  static String buildVideoUrl(String uri) => (uri == null) ? null : '$apiVideoUrlPrefix$uri';
}

abstract class TmdbApiBase {
  final apiKey = 'ffea4ca1099c6f945cfe912e08056be2';
  final includeAdult = true;
}

mixin ApiResponseDecodeMixin on TmdbApiBase {
  /// Checa o stats code de um [http.Response], e retorna `true` se este for igual a 200.
  dynamic checkStatusCode(http.Response response, {String errMsg}) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 401:
        throw Exception('TMDb fail! Invalid API key: You must be granted a valid key.');
      case 404:
        throw Exception('THDb fail! The resource you requested could not be foung.');
      default:
        throw Exception('TMDb fail! ${errMsg ?? ''}');
    }
  }
}

class ApiMovies extends TmdbApiBase with ApiResponseDecodeMixin {
  Future<MovieDetails> details(Movie movie) async {
    final http.Response response = await http.get('https://api.themoviedb.org/3/movie/'
        '${movie.idString}'
        '?api_key=$apiKey'
        '&append_to_response=videos');
    return _decodeDetails(movie, response);
  }

  MovieDetails _decodeDetails(Movie movie, http.Response response) {
    var decoded = checkStatusCode(response, errMsg: 'Failed to load movie details.');
    if (decoded == null) return null;
    return MovieDetails.fromJson(movie, decoded);
  }
}

class ApiSearch extends TmdbApiBase with ApiResponseDecodeMixin {
  String _query;
  int _page;
  int _totalPages;

  bool get hasNextPage => (_totalPages is int) ? (_totalPages > _page) : false;

  Future<List<Movie>> movies({String query, bool nextPage = false}) async {
    if (query == null || nextPage) {
      // Next page.
      _page++;
    } else {
      // New search.
      _query = query;
      _page = 1;
    }

    final http.Response response = await http.get('https://api.themoviedb.org/3/search/movie'
        '?api_key=$apiKey'
        '&query=$_query'
        '&page=$_page'
        '&include_adult=$includeAdult');
    return _decodeMovies(response);
  }

  Future<List<MovieSearchSuggestion>> keywords(String query) async {
    final http.Response response = await http.get('https://api.themoviedb.org/3/search/multi'
        '?api_key=$apiKey'
        '&query=$query'
        '&page=1'
        '&include_adult=$includeAdult');
    return _decodeKeywords(response);
  }

  List<Movie> _decodeMovies(http.Response response) {
    var decoded = checkStatusCode(response, errMsg: 'Failed to load movies.');
    if (decoded == null) return null;

    _page = decoded['page'];
    _totalPages = decoded['total_pages'];
    return decoded['results'].map<Movie>((m) => Movie.fromJson(m)).toList();
  }

  List<MovieSearchSuggestion> _decodeKeywords(http.Response response) {
    var decoded = checkStatusCode(response, errMsg: 'Failed to load search suggestions.');
    if (decoded == null) return null;

    return decoded['results']
        .where((s) => s['media_type'] == 'movie')
        .toList()
        .map<MovieSearchSuggestion>((s) => MovieSearchSuggestion.fromJson(s))
        .toList();
  }
}
