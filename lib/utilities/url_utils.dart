bool isNetworkUrl(String value) {
  final normalized = value.trim();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}
