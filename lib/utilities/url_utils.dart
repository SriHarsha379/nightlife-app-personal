/// Determines whether [value] is an HTTP/HTTPS URL with a non-empty host.
///
/// This validates parsed URL structure instead of relying on simple prefix
/// checks like
/// `value.startsWith('http://') || value.startsWith('https://')`.
///
/// Examples:
/// - `http://` => `false`
/// - `https://localhost` => `true`
/// - `http://example.com/path` => `true`
/// - `assets/image.png` => `false`
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

/// Resolves any image path/value coming from the API into a displayable URL.
///
/// - Empty/null -> ''
/// - Already a full URL (e.g. seeded placeholder, CDN link) -> returned as-is
/// - Relative filename (e.g. 'image-123.jpg') -> prefixed with [baseUrl]
///
/// Use this instead of manually writing '${AppConfigProvider.imageUrl}$path'
/// everywhere - that pattern breaks as soon as a field contains a full URL.
String resolveImageUrl(dynamic path, String baseUrl) {
  final value = (path ?? '').toString().trim();
  if (value.isEmpty) return '';
  if (isNetworkUrl(value)) return value;
  return '$baseUrl$value';
}
