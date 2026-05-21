/// Returns `true` when [value] is an HTTP(S) URL.
bool isNetworkUrl(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;
  final uri = Uri.tryParse(normalized);
  if (uri == null) return false;
  final host = uri.host.trim();
  final scheme = uri.scheme.toLowerCase();
  return (scheme == 'http' || scheme == 'https') && host.isNotEmpty;
}
