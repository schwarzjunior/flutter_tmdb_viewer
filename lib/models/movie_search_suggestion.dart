class MovieSearchSuggestion {
  final String mediaType;
  final String title;

  const MovieSearchSuggestion({this.mediaType, this.title});

  factory MovieSearchSuggestion.fromJson(Map<String, dynamic> json) {
    return MovieSearchSuggestion(
      mediaType: json['media_type'],
      title: json['title'] ?? json['name'],
    );
  }
}
