import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/blocs/movies_bloc.dart';
import 'package:tmdb_viewer/delegates/data_search.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/ui/screens/favorites_page.dart';
import 'package:tmdb_viewer/ui/widgets/movie_tile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moviesBloc = BlocProvider.getBloc<MoviesBloc>();
    final favBloc = BlocProvider.getBloc<FavoritesBloc>();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Container(
          height: 35,
          child: Image.asset('images/tmdb-powered-by-rectangle-green.png'),
        ),
        elevation: 0,
        backgroundColor: Colors.black87,
        actions: <Widget>[
          Align(
            alignment: const Alignment(0, 0),
            child: StreamBuilder<Map<String, Movie>>(
              stream: favBloc.outFav,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('${snapshot.data.length}',
                      style: Theme.of(context).textTheme.title.copyWith(
                            color: Colors.white,
                          ));
                } else {
                  return Container();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Favoritos',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FavoritesPage(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar',
            onPressed: () async {
              String result = await showSearch(context: context, delegate: DataSearch());
              if (result != null) moviesBloc.inSearch.add(result);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: moviesBloc.outMovies,
        initialData: [],
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          return ListView.builder(
            itemCount: snapshot.data.length + (moviesBloc.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < snapshot.data.length) {
                return MovieTile(snapshot.data[index]);
              } else {
                moviesBloc.inSearch.add(null);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 40,
                  width: 40,
                  alignment: const Alignment(0, 0),
                  child: const CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
