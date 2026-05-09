class AppConfig {
  /// Base URL for the Aura Weather API.
  /// Include the protocol, host, port, and base path.
  ///
  /// Must be supplied at build time via --dart-define or --dart-define-from-file:
  ///   flutter run --dart-define=AURA_API_BASE_URL=YOUR_API_BASE_URL
  ///   flutter run --dart-define-from-file=.env.json
  static final String apiBaseUrl = _loadApiBaseUrl();

  static String _loadApiBaseUrl() {
    const url = String.fromEnvironment('AURA_API_BASE_URL');
    if (url.isEmpty) {
      throw StateError(
        'AURA_API_BASE_URL is not set.\n'
        'Run with --dart-define=AURA_API_BASE_URL=<url> or\n'
        '--dart-define-from-file=.env.json\n'
        'See README.md for setup instructions.',
      );
    }
    return url;
  }
}
