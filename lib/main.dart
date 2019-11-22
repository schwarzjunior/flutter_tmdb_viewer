import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_theme_mode/flutter_dynamic_theme_mode.dart';
import 'package:tmdb_viewer/blocs/favorites_bloc.dart';
import 'package:tmdb_viewer/blocs/movies_bloc.dart';
import 'package:tmdb_viewer/ui/screens/home_page.dart';
import 'package:tmdb_viewer/ui/theme.dart' as app_themes;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicThemeApp(
      theme: app_themes.lightTheme,
      darkTheme: app_themes.darkTheme,
      defaultThemeMode: ThemeMode.light,
      builder: (context, data) {
        return BlocProvider(
          blocs: [
            Bloc((i) => MoviesBloc()),
            Bloc((i) => FavoritesBloc()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'tmdb_viewer',
            theme: data.theme,
            darkTheme: data.darkTheme,
            themeMode: data.mode,
            home: HomePage(),
          ),
        );
      },
    );
  }
}
