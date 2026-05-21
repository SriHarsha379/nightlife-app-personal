bool isNetworkUrl(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}
