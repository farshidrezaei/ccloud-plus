enum MediaType {
  movie('movie', 'فیلم'),
  series('series', 'سریال'),
  channel('channel', 'شبکه');

  final String value;
  final String titleFa;

  const MediaType(this.value, this.titleFa);

  static MediaType fromString(String? val) {
    if (val == 'series') return MediaType.series;
    if (val == 'channel') return MediaType.channel;
    return MediaType.movie;
  }

  bool get isMovie => this == MediaType.movie;
  bool get isSeries => this == MediaType.series;
}
