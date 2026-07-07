# Nature Sounds

Free nature sounds app for sleep and relaxation. No ads, no tracking, no subscriptions.

## Download

Download the latest APK from [GitHub Actions](https://github.com/zeroasterisk/nature-sounds/actions) → latest successful run → Artifacts → `nature-sounds-apk`.

## Features

- **16 nature sounds**: waves, rain, heavy rain, forest, birds, river, stream, crickets, locusts, thunder, wind, campfire, fan, brown noise, white noise, pink noise
- **Seamless looping**: all sounds crossfade perfectly for infinite playback
- **Sleep timer**: ∞, 6h, 4h, 2h, 1h, 30m with 2-minute fade-out
- **Favorites**: tap the heart to save your favorite sounds
- **Recents**: recently played sounds for quick access
- **Dark theme**: soft muted colors designed for bedtime use

## Screenshots

(Coming soon — install the APK and see for yourself!)

## Tech

- Flutter (Android-first, iOS later)
- Material Design 3 with custom dark theme
- `just_audio` for seamless audio looping
- `shared_preferences` for favorites/recents persistence
- `provider` for state management
- Synthetic sounds generated with numpy/scipy (zero licensing risk)

## Building

```bash
flutter pub get
flutter build apk --release
# APK at build/app/outputs/flutter-apk/app-release.apk
```

## Sound Generation

All sounds are synthesized programmatically — no external recordings, no licensing concerns. Each sound is 30 seconds with a 2-second crossfade at the loop point for seamless infinite playback.

## License

MIT
