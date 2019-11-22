import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'package:tmdb_viewer/api/tmdb_api.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/models/movie_details.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:tmdb_viewer/utils/formatters.dart' as fmt;

class MovieDetailsPage extends StatelessWidget {
  final Movie movie;

  final ApiMovies _apiMovies;
  static TextTheme _textTheme;

  MovieDetailsPage(this.movie, {Key key})
      : _apiMovies = ApiMovies(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        centerTitle: true,
      ),
      body: FutureBuilder<MovieDetails>(
        future: getDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final MovieDetails movieDetails = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Poster e titulo do filme.
                MoviePosterWidget(movieDetails),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Tagline do filme.
                      _buildTaglineVoteAverage(movieDetails),
                      // Overview do filme.
                      _buildOverview(movieDetails),
                      _divider,
                      _buildInfoLine('Status:', movieDetails.status),
                      const SizedBox(height: 8),
                      _buildInfoLine('Budget:', fmt.formatCurrency(movieDetails.budget)),
                      const SizedBox(height: 8),
                      _buildInfoLine('Revenue:', fmt.formatCurrency(movieDetails.revenue)),
                      _divider,
                      // Lista de videos.
                      _buildVideosList(movieDetails),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverview(MovieDetails movieDetails) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: Text(
        movieDetails.movie.overview,
        textAlign: TextAlign.justify,
        style: _textTheme.body1,
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(label, style: _textTheme.subhead),
        ),
        Expanded(
          child: Text(value, style: _textTheme.subhead.copyWith(color: Colors.white60)),
        ),
      ],
    );
  }

  Widget _buildTaglineVoteAverage(MovieDetails movieDetails) {
    final voteAverage = (movieDetails.movie.voteAverage * 10).toInt();
    final voteAverageText = voteAverage == 0 ? 'ND' : voteAverage.toString().padLeft(voteAverage < 10 ? 2 : 3, ' ');
    final voteAverageColor =
        voteAverage == 0 ? Colors.grey : (voteAverage >= 70 ? Colors.lightGreenAccent[700] : Colors.yellowAccent[400]);

    return Row(
      children: <Widget>[
        // Tagline.
        Expanded(
          child: Text(
            movieDetails.tagline,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _textTheme.subtitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Vote average.
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: voteAverageColor, width: 5),
            borderRadius: const BorderRadius.all(const Radius.circular(32.5)),
          ),
          width: 65,
          height: 65,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  voteAverageText,
                  style: _textTheme.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  voteAverage == 0 ? '' : '%',
                  style: _textTheme.body2.copyWith(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideosList(MovieDetails movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Videos { ${movieDetails.videos.length.toString().padLeft(2, '0')} } :',
          style: _textTheme.subhead,
        ),
        ListView.builder(
          padding: const EdgeInsets.only(left: 4, top: 8),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: movieDetails.videos.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                child: Text(
                  movieDetails.videos[index].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _textTheme.body2,
                ),
                onTap: () {
                  _openYoutubeVideo(movieDetails.videos[index].key);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget get _divider {
    return const Divider(height: 32, thickness: 0.3);
  }

  _openYoutubeVideo(String key) async {
    final url = ApiFunctions.buildVideoUrl(key);
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    }
  }

  Future<MovieDetails> getDetails() async => await _apiMovies.details(movie);
}

/// Widget com a imagem do poster e o titulo do filme
class MoviePosterWidget extends StatelessWidget {
  final MovieDetails movieDetails;

  const MoviePosterWidget(this.movieDetails, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favBloc = BlocProvider.getBloc<FavoritesBloc>();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildImageWidget(context),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  movieDetails.movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2, 2),
                        color: Colors.black87,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                movieDetails.movie.releaseDateYear,
                style: Theme.of(context).textTheme.title.copyWith(
                  color: Colors.white.withAlpha(200),
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1, 1),
                      color: Colors.black87,
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: StreamBuilder<Map<String, Movie>>(
            stream: favBloc.outFav,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              final isFavorite = snapshot.data.containsKey(movieDetails.movie.idString);
              return IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                color: isFavorite ? Colors.yellowAccent : Colors.white,
                iconSize: 30,
                onPressed: () {
                  favBloc.toggleFavorite(movieDetails.movie);
                },
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: Icon(Icons.open_in_new),
            color: Colors.white.withAlpha(200),
            iconSize: 30,
            tooltip: 'Go to homepage',
            onPressed: () {
              // TODO: Open movie homepage.
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    final imgUrl = movieDetails.movie.getImagePath();
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: imgUrl != null
          ? Image.network(
              imgUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, chunkEvent) => Center(child: child),
            )
          : const Icon(Icons.local_movies, size: 60, color: Colors.white38),
    );
  }
}
