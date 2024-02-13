class WordsBookmarksModel {
  final String verseKey;
  final int position;
  final String surahName;
  final int surahId, page, juz;

  WordsBookmarksModel(this.verseKey, this.position, this.surahName,
      this.surahId, this.page, this.juz);
}
