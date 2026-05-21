/// Returns `true` when [value] is an HTTP(S) URL.
bool isNetworkUrl(String value) {
  final normalized = value.trim();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}
