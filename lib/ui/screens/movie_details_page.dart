import 'package:flutter/material.dart';
import 'package:tmdb_viewer/api.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/models/movie_details.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class MovieDetailsPage extends StatelessWidget {
  final Movie movie;
  final Api _api;
  static TextTheme _textTheme;

  MovieDetailsPage(this.movie, {Key key})
      : _api = Api(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(movie.title),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: FutureBuilder<MovieDetails>(
        future: getDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final MovieDetails movieDetails = snapshot.data;
//          print('${movie.voteCount}');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // movie poster e titulo
                MoviePosterWidget(movieDetails),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // tagline do filme
                      _buildTaglineVoteAverage(movieDetails),
                      // overview do filme
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                        child: Text(
                          movie.overview,
                          textAlign: TextAlign.justify,
                          style: _textTheme.body1.copyWith(color: Colors.white70),
                        ),
                      ),
                      _divider,
                      // budget
                      _buildBudget(movieDetails),
                      _divider,
                      // lista de videos
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

  Widget _buildBudget(MovieDetails movieDetails) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            'Budget:',
            style: _textTheme.subhead.copyWith(color: Colors.white),
          ),
        ),
        Expanded(
          child: Text(
            '\$${movieDetails.budget.toStringAsFixed(2)}',
            style: _textTheme.subhead.copyWith(color: Colors.white60),
          ),
        ),
      ],
    );
  }

  Widget _buildTaglineVoteAverage(MovieDetails movieDetails) {
    final voteAverage = (movieDetails.movie.voteAverage * 10).toInt();
    final voteAverageText = voteAverage == 0
        ? 'ND'
        : voteAverage.toString().padLeft(voteAverage < 10 ? 2 : 3, ' ');
    final voteAverageColor = voteAverage == 0
        ? Colors.grey
        : (voteAverage >= 70 ? Colors.lightGreenAccent[700] : Colors.yellowAccent[400]);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            movieDetails.tagline,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _textTheme.subtitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
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
                    color: Colors.white,
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
          style: _textTheme.subhead.copyWith(color: Colors.white),
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
                  style: _textTheme.body1.copyWith(color: Colors.white60),
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
    return Divider(height: 32, thickness: 1.5, color: Colors.white60.withAlpha(40));
  }

  _openYoutubeVideo(String key) async {
    final url = '$youtubeVideoUrlPrefix$key';
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    }
  }

  Future<MovieDetails> getDetails() async => await _api.getDetails(movie);
}

/// Widget com a imagem do poster e o titulo do filme
class MoviePosterWidget extends StatelessWidget {
  final MovieDetails movieDetails;

  const MoviePosterWidget(this.movieDetails, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white,
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
