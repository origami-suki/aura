import 'package:flutter_test/flutter_test.dart';
import 'package:aura_weather/config/app_config.dart';

void main() {
  test('AppConfig.apiBaseUrl behavior', () {
    const defined = bool.hasEnvironment('AURA_API_BASE_URL');
    const definedApiBaseUrl = String.fromEnvironment('AURA_API_BASE_URL');

    if (defined) {
      expect(AppConfig.apiBaseUrl, definedApiBaseUrl);
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    } else {
      expect(
        () => AppConfig.apiBaseUrl,
        throwsStateError,
      );
    }
  });
}
