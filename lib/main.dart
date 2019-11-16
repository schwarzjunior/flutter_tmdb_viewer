import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/blocs/movies_bloc.dart';
import 'package:tmdb_viewer/ui/screens/home_page.dart';
import 'package:tmdb_viewer/ui/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => MoviesBloc()),
        Bloc((i) => FavoritesBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'tmdb_viewer',
        theme: myTheme,
        /*theme: ThemeData(
//        brightness: Brightness.dark,
          primarySwatch: Colors.green,
        ),*/

        home: HomePage(),
      ),
    );
  }
}
