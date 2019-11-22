import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_viewer/api.dart';
import 'package:tmdb_viewer/api/tmdb_api.dart';
import 'package:tmdb_viewer/models/movie_search_suggestion.dart';

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.delayed(Duration.zero).then((_) => close(context, query.isEmpty ? null : query));
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Container();

    return FutureBuilder<List<MovieSearchSuggestion>>(
      future: suggestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            IconData icon;
            if (snapshot.data[index].mediaType == 'movie')
              icon = Icons.local_movies;
            else if (snapshot.data[index].mediaType == 'tv')
              icon = Icons.live_tv;
            else
              icon = Icons.play_arrow;
            return ListTile(
              title: Text(snapshot.data[index].title ?? ''),
              leading: Icon(icon),
              onTap: () {
                close(context, snapshot.data[index].title);
              },
            );
          },
        );
      },
    );
  }

  Future<List<MovieSearchSuggestion>> suggestions(String search) async {
    final api = ApiSearch();
    return await api.keywords(search);
  }

  Future<List<MovieSearchSuggestion>> suggestions2(String search) async {
    final api = Api();
    return await api.suggestions(search);
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);
}
