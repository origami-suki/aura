# aura

Aura Weather — a Flutter weather application.

## Setup

The API base URL is supplied at build time via Dart environment variables:

```bash
# Copy the example env file and edit the URL
cp .env.example.json .env.json

# Run the app
flutter run --dart-define-from-file=.env.json
```

For one-off runs without a file:

```bash
flutter run --dart-define=AURA_API_BASE_URL=<api-base-url>
```

`flutter analyze` and `flutter test` also accept these flags:

```bash
flutter test --dart-define=AURA_API_BASE_URL=https://example.test/api/v1
```

## Credits

Aura's weather atmosphere and Material 3 UI polish reference [Breezy Weather](https://github.com/breezy-weather/breezy-weather), especially its condition-aware gradients, cross-faded weather views, and dynamic color direction. Aura adapts those visual/UI ideas while remaining its own Flutter implementation.

Weather icons are pixel art assets from [pixel-icon-provider](https://github.com/breezy-weather/pixel-icon-provider), an open-source rewrite of Geometric Weather's pixel icon provider, originally created by [Wangdayeeeeeee](https://github.com/WangDaYeeeeee).
