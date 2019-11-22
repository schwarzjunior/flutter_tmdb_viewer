import 'package:tmdb_viewer/api/tmdb_api.dart';

class Movie extends MovieBase {
  Movie({
    int id,
    String title,
    String overview,
    String releaseDate,
    bool adult,
    int voteCount,
    num voteAverage,
    num popularity,
    String posterPath,
    String backdropPath,
  }) : super(id, title, overview, releaseDate, adult, voteCount, voteAverage, popularity, posterPath, backdropPath);

  factory Movie.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id')) {
      // json originario do imdb.
      return Movie(
          id: json['id'],
          title: json['title'],
          overview: json['overview'],
          releaseDate: json['release_date'],
          adult: json['adult'],
          voteCount: json['vote_count'],
          voteAverage: json['vote_average'],
          popularity: json['popularity'],
          posterPath: ApiFunctions.buildImageUrl(json['poster_path']),
          backdropPath: ApiFunctions.buildImageUrl(json['backdrop_path']));
    } else {
      return Movie(
          id: json['movie_id'],
          title: json['title'],
          overview: json['overview'],
          releaseDate: json['release_date'],
          adult: json['adult'],
          voteCount: json['vote_count'],
          voteAverage: json['vote_average'],
          popularity: json['popularity'],
          posterPath: json['poster_path'],
          backdropPath: json['backdrop_path']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': id,
      'title': title,
      'overview': overview,
      'release_date': releaseDate,
      'adult': adult,
      'vote_count': voteCount,
      'vote_average': voteAverage,
      'popularity': popularity,
      'poster_path': posterPath,
      'backdrop_path': backdropPath
    };
  }
}

class MovieBase {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final bool adult;
  final int voteCount;
  final num voteAverage;
  final num popularity;
  final String posterPath;
  final String backdropPath;

  MovieBase(
    this.id,
    this.title,
    this.overview,
    this.releaseDate,
    this.adult,
    this.voteCount,
    this.voteAverage,
    this.popularity,
    this.posterPath,
    this.backdropPath,
  );

  String get idString => id.toString();

  String get releaseDateYear {
    final DateTime dt = DateTime.tryParse(releaseDate ?? '');
    return dt != null ? dt.year.toString().padLeft(2, '0') : null;
  }

  String getImagePath({bool backdropFirst = true}) {
    if (backdropPath == null && posterPath == null) return null;
    return backdropFirst ? (backdropPath ?? posterPath) : (posterPath ?? backdropPath);
  }

  @override
  String toString() => '$runtimeType [id: $id, title: $title, '
      'releaseDate: $releaseDate, adult: $adult, '
      'posterPath: $posterPath, backdropPath: $backdropPath, '
      'voteCount: $voteCount, voteAverage: $voteAverage, popularity: $popularity]';

/*@override
  String toString() => 'MovieBase [id: $id, title: $title, '
      'releaseDate: $releaseDate, adult: $adult, '
      'hasPoster: ${posterPath != null}, hasBackdrop: ${backdropPath != null}, '
      'voteCount: $voteCount, voteAverage: $voteAverage, popularity: $posterPath]';*/
}
