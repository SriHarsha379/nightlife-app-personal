class NameFormatter {
  /// "sri  harsha" -> "Sri Harsha". Trims, collapses repeated spaces and
  /// raises only the first letter of each word; the rest is left as typed
  /// (so "McDonald" stays "McDonald").
  static String capitalizeWords(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
