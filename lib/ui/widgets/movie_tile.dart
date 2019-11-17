import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/ui/screens/movie_details_page.dart';

class MovieTile extends StatelessWidget {
  final Movie movie;

  const MovieTile(this.movie, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favBloc = BlocProvider.getBloc<FavoritesBloc>();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MovieDetailsPage(movie),
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildImageWidget(context),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(movie.title,
                            maxLines: 2, style: Theme.of(context).textTheme.title),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Year: ${movie.releaseDateYear}',
                            style: Theme.of(context).textTheme.subtitle),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Map<String, Movie>>(
                  stream: favBloc.outFav,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return IconButton(
                        icon: Icon(snapshot.data.containsKey(movie.idString)
                            ? Icons.star
                            : Icons.star_border),
                        color: Colors.white,
                        iconSize: 30,
                        onPressed: () {
                          favBloc.toggleFavorite(movie);
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    final imgUrl = movie.getImagePath();
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
