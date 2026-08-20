class EpubViewChapter {
  EpubViewChapter(this.title, this.startIndex);

  final String? title;
  final int startIndex;

  String get type => this is EpubViewSubChapter ? 'subchapter' : 'chapter';

  @override
  String toString() => '$type: {title: $title, startIndex: $startIndex}';
}

class EpubViewSubChapter extends EpubViewChapter {
  EpubViewSubChapter(super.title, super.startIndex);
}
