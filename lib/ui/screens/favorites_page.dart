import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/ui/screens/movie_details_page.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favBloc = BlocProvider.getBloc<FavoritesBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, Movie>>(
        stream: favBloc.outFav,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          if (snapshot.data.isEmpty) return _wFavoritesEmpty(context);

          return ListView.separated(
            itemCount: snapshot.data.length,
            separatorBuilder: (context, index) => Divider(
              thickness: 0.3,
            ),
            itemBuilder: (context, index) {
              final Movie movie = snapshot.data.values.elementAt(index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MovieDetailsPage(movie),
                    ));
                  },
                  onLongPress: () {
                    // remove dos favoritos.
                    favBloc.toggleFavorite(movie);
                  },
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        _buildImageWidget(context, movie),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                movie.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .title
                                    .copyWith(color: Colors.white70, fontSize: 18),
                              ),
                              Text(
                                'Year: ${movie.releaseDateYear}',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle
                                    .copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, Movie movie) {
    final imgUrl = movie.getImagePath();
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 100,
      child: imgUrl != null
          ? Image.network(
              imgUrl,
              fit: BoxFit.scaleDown,
              loadingBuilder: (context, child, chunkEvent) => Center(child: child),
            )
          // TODO: Icon color (remover)
          : const Icon(Icons.movie_filter, size: 40, color: Colors.white38),
//          : const Icon(Icons.local_movies, size: 40, color: Colors.white38),
    );
  }

  Widget _wFavoritesEmpty(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.layers_clear, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 15),
          Text(
            'Nenhum favorito encontrado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
//            style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
