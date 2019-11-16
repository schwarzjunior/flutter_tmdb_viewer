import 'package:tmdb_viewer/models/movie.dart';

class MovieDetails {
  final Movie movie;
  final int budget;
  final String homepage;
  final String imdbId;
  final int revenue;
  final List<MovieGenre> genres;
  final List<MovieLanguage> spokenLanguages;
  final List<MovieVideo> videos;
  final String status;
  final String tagline;

  MovieDetails({
    this.movie,
    this.budget,
    this.homepage,
    this.imdbId,
    this.revenue,
    this.genres,
    this.spokenLanguages,
    this.videos,
    this.status,
    this.tagline,
  });

  factory MovieDetails.fromJson(Movie movie, Map<String, dynamic> json) {
    return MovieDetails(
        movie: movie,
        budget: json['budget'],
        homepage: json['homepage'],
        imdbId: json['imdb_id'],
        revenue: json['revenue'],
        genres: json['genres']
            .map<MovieGenre>(
              (mg) => MovieGenre.fromJson(mg),
            )
            .toList(),
        spokenLanguages: json['spoken_languages']
            .map<MovieLanguage>(
              (ml) => MovieLanguage.fromJson(ml),
            )
            .toList(),
        videos: json['videos']['results']
            .map<MovieVideo>(
              (mv) => MovieVideo.fromJson(mv),
            )
            .toList(),
        status: json['status'],
        tagline: json['tagline']);
  }

  @override
  String toString() => 'MovieDetails [movie: ${movie.title}, '
      'budget: $budget, homepage: $homepage, imdbId: $imdbId, '
      'revenue: $revenue, status: $status, tagline: $tagline, '
      'genres: $genres, videos: $videos, languages: $spokenLanguages]';
}

class MovieGenre {
  final int id;
  final String name;

  MovieGenre({this.id, this.name});

  factory MovieGenre.fromJson(Map<String, dynamic> json) {
    return MovieGenre(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() => 'MovieGenre [id: $id, name: $name]';
}

class MovieVideo {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;
  final int size;

  MovieVideo({this.id, this.name, this.key, this.site, this.type, this.size});

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'],
      name: json['name'],
      key: json['key'],
      site: json['site'],
      type: json['type'],
      size: json['size'],
    );
  }

  @override
  String toString() => 'MovieVideo [id: $id, name: $name, '
      'key: $key, site: $site, type: $type, size: $size]';
}

class MovieLanguage {
  final String code;
  final String name;

  MovieLanguage({this.code, this.name});

  factory MovieLanguage.fromJson(Map<String, dynamic> json) {
    return MovieLanguage(
      code: json['code'],
      name: json['name'],
    );
  }

  @override
  String toString() => 'MovieLanguages [code: $code, name: $name]';
}
