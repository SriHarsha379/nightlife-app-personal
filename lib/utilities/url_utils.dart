/// Determines whether [value] is an HTTP/HTTPS URL with a non-empty host.
bool isNetworkUrl(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;
  final uri = Uri.tryParse(normalized);
  if (uri == null) return false;
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return false;
  final host = uri.host.trim();
  return host.isNotEmpty;
}
