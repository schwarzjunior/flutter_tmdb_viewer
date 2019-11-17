import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/blocs/movies_bloc.dart';
import 'package:tmdb_viewer/delegates/data_search.dart';
import 'package:tmdb_viewer/models/movie.dart';
import 'package:tmdb_viewer/ui/screens/about_page.dart';
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
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AboutPage(),
            ));
          },
          child: Container(
            height: 35,
            child: Image.asset('images/tmdb-powered-by-rectangle-green.png'),
          ),
        ),
        elevation: 0,
        actions: <Widget>[
          Align(
            alignment: const Alignment(0, 0),
            child: StreamBuilder<Map<String, Movie>>(
              stream: favBloc.outFav,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data.length}',
                    style: Theme.of(context).textTheme.title,
                  );
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
//        initialData: [],
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data.isEmpty) return _wSearchResultsEmpty(context);

          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView.builder(
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
            ),
          );
        },
      ),
    );
  }

  Widget _wSearchResultsEmpty(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
//          Icon(Icons.block, size: 120, color: Colors.grey[400]),
//          Icon(Icons.cancel, size: 120, color: Colors.grey[400]),
//          Icon(Icons.description, size: 120, color: Colors.grey[400]),
//          Icon(Icons.highlight_off, size: 120, color: Colors.grey[400]),
//          Icon(Icons.remove_circle_outline, size: 120, color: Colors.grey[400]),
          Icon(Icons.sentiment_dissatisfied, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 15),
          Text(
            'Nenhum resultado encontrado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
