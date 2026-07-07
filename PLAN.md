# Nature Sounds — Implementation Plan

**Target:** Buildable tonight (6–8 hrs), APK from GitHub Actions tomorrow morning, sideload on Pixel 8.

---

## 1. File Structure

```
nature_sounds/
├── .github/
│   └── workflows/
│       └── build-apk.yml
├── android/                        # default, minSdk 24
├── ios/                            # default (phase 2)
├── assets/
│   └── sounds/
│       ├── waves.ogg
│       ├── rain.ogg
│       ├── forest.ogg
│       ├── locusts.ogg
│       ├── brown_noise.ogg
│       ├── white_noise.ogg
│       ├── pink_noise.ogg
│       ├── fan.ogg
│       ├── wind.ogg
│       ├── thunder.ogg
│       ├── campfire.ogg
│       ├── river.ogg
│       ├── crickets.ogg
│       ├── birds.ogg
│       ├── heavy_rain.ogg
│       └── stream.ogg
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp, theme
│   ├── theme/
│   │   └── app_theme.dart          # colors, text styles
│   ├── models/
│   │   └── sound.dart              # Sound model + static catalog
│   ├── services/
│   │   ├── audio_service.dart      # playback, looping, fade-out
│   │   ├── timer_service.dart      # duration countdown
│   │   └── prefs_service.dart      # favorites/recents persistence
│   ├── state/
│   │   └── app_state.dart          # ChangeNotifier (single store)
│   ├── screens/
│   │   └── home_screen.dart        # single-screen app
│   └── widgets/
│       ├── sound_card.dart
│       ├── duration_selector.dart
│       ├── now_playing_bar.dart
│       └── section_header.dart
├── tools/
│   └── generate_noise.py           # generates brown/white/pink noise
├── pubspec.yaml
├── LICENSE                         # MIT
├── CREDITS.md                      # sound attributions
└── README.md
```

**Deliberately a single-screen app.** No routing, no bottom nav. Favorites/Recents are horizontal sections above the main grid. This is the biggest time-saver.

---

## 2. Sound Sourcing Strategy (15+ sounds, ~1 hr)

### A. Generate synthetically (guaranteed seamless, zero licensing risk)

Use `tools/generate_noise.py` with numpy + scipy (5 minutes to write):

| Sound | Method |
|---|---|
| `brown_noise.ogg` | Cumulative sum of white noise, normalized, high-pass at 20Hz |
| `white_noise.ogg` | `np.random.randn` |
| `pink_noise.ogg` | White noise filtered −3dB/octave (Voss or FFT method) |
| `fan.ogg` | Brown noise + gentle band-pass ~100–400Hz + subtle 20Hz amplitude modulation |
| `wind.ogg` | Pink noise with slow random LFO on a low-pass filter cutoff |

Generate 60-second files. Because they're stochastic, make the loop seamless by **crossfading the last 2s with the first 2s** in the script before export.

### B. Source from Freesound.org / Pixabay (CC0 filter only)

- **Freesound.org**: search with license filter = "Creative Commons 0". Good queries: "rain loop", "ocean waves loop", "campfire crackling", "forest ambience", "cicadas", "river", "thunder rain", "crickets night".
- **Pixabay.com/sound-effects**: everything is free for commercial use, no attribution required — fastest option.
- Record each source in `CREDITS.md` (URL, author, license) even for CC0 — good hygiene for a public repo.

### C. Post-process everything in one pass (script or Audacity batch)

For each downloaded file:
1. Trim to 60–120 seconds.
2. **Seamless loop treatment:** cut file in half, swap halves, crossfade the new join point (now mid-file), so the file's start/end are the original continuous middle. Or simpler: 2s crossfade of tail into head.
3. Normalize to −16 LUFS-ish (just peak-normalize to −3dB is fine tonight).
4. Export as **OGG Vorbis, 96–128 kbps, 44.1kHz**.

**Why OGG:** MP3 has encoder padding (gap at loop point); OGG and WAV are gapless. OGG keeps assets small (~1MB/min). Target total assets < 25MB.

---

## 3. Core App Architecture

### State management: `provider` + `ChangeNotifier`

Don't use Riverpod/Bloc tonight — one `AppState` ChangeNotifier is enough:

```dart
class AppState extends ChangeNotifier {
  Sound? currentSound;
  bool isPlaying = false;
  SleepDuration duration = SleepDuration.infinity;
  Duration? remaining;              // ticked by TimerService
  List<String> favoriteIds = [];
  List<String> recentIds = [];      // max 6, most-recent-first
  double volume = 1.0;
}
```

### Packages (`pubspec.yaml`)

```yaml
dependencies:
  flutter: { sdk: flutter }
  just_audio: ^0.9.42          # gapless looping via LoopMode.one
  audio_session: ^0.1.21       # media audio session config
  audio_service: ^0.18.15      # background playback + media notification (Android)
  provider: ^6.1.2
  shared_preferences: ^2.3.2   # favorites, recents
  wakelock_plus: ^1.2.8        # optional: keep alive while screen on (not required with audio_service)
```

**`audio_service` is what makes it work for sleeping** — playback continues with screen off, with a media notification (play/pause). If it fights you at hour 5, fallback: `just_audio` alone + Android foreground service via just_audio's built-in `androidAudioAttributes` and accept notification-less background play won't survive Doze — but `audio_service` is the correct answer and well-documented with just_audio.

### Services

- **`audio_service.dart`** — wraps `AudioPlayer` from just_audio inside an `AudioHandler`. Exposes `play(Sound)`, `pause()`, `stop()`, `setVolume(double)`.
- **`timer_service.dart`** — `Timer.periodic(1s)`. When remaining ≤ 2 min, calls `audioService.setVolume(remaining.inSeconds / 120)` each tick (linear fade); at 0, stop + reset volume.
- **`prefs_service.dart`** — `getStringList('favorites')` / `('recents')`; write-through on every change.

### Model

```dart
class Sound {
  final String id;         // 'waves'
  final String name;       // 'Ocean Waves'
  final String assetPath;  // 'assets/sounds/waves.ogg'
  final IconData icon;     // Icons.waves
  final Color tint;        // per-card accent
}
// static const List<Sound> catalog = [ ... 16 entries ... ];
```

Catalog is hardcoded — no JSON, no database.

---

## 4. UI Design

### Palette (soft, muted, dark-leaning for nighttime use)

| Role | Hex |
|---|---|
| Background | `#1A2027` (deep blue-charcoal) |
| Surface / cards | `#242C35` |
| Card pressed/playing | `#2E3A45` |
| Primary accent | `#8FBCBB` (muted teal) |
| Secondary accent | `#A3B18A` (sage green) |
| Text primary | `#E8EDF2` |
| Text secondary | `#94A3B2` |
| Favorite heart | `#D4A5A5` (dusty rose) |
| Fade/timer indicator | `#C8B8DB` (soft lavender) |

Per-card tints (icon + subtle glow when playing): waves `#7EA8BE`, rain `#8DA9C4`, forest `#A3B18A`, campfire `#D9A47E`, thunder `#9E8FB2`, brown noise `#B0A08F`, etc.

Theme: `ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF8FBCBB), brightness: Brightness.dark))`, then override `scaffoldBackgroundColor` and `cardColor`. Font: default Roboto (skip google_fonts to save time; optionally `google_fonts` Nunito if time permits).

### Single screen layout (`home_screen.dart`)

```
┌────────────────────────────┐
│  Nature Sounds        (⏱)  │  ← AppBar: title + timer chip showing remaining
│                            │
│  ♥ Favorites               │  ← horizontal ListView, 88px pill cards (hidden if empty)
│  [🌊] [🔥] [🌧]             │
│                            │
│  ⏱ Recent                  │  ← same style (hidden if empty)
│  [🌲] [💨]                  │
│                            │
│  All Sounds                │
│  ┌──────┐ ┌──────┐         │  ← GridView.count, crossAxisCount: 2,
│  │ 🌊   │ │ 🌧   │         │     aspect 1.4, 12px spacing
│  │Waves │ │ Rain │  ♥      │     heart icon top-right (toggle favorite)
│  └──────┘ └──────┘         │     playing card: tinted border + pulsing icon
│  ...                       │
├────────────────────────────┤
│ ▶ Waves      ∞ 6h 4h 2h 1h ½│ ← NowPlayingBar (only when sound selected):
└────────────────────────────┘    play/pause, name, duration ChoiceChips
```

### Components

- **`sound_card.dart`** — `Card` with `InkWell`, icon (48px, tinted), name, heart `IconButton`. Playing state: `Border.all(color: tint, width: 2)` + `AnimatedScale` subtle pulse (skip animation if short on time).
- **`duration_selector.dart`** — row of `ChoiceChip`s: `∞ · 6h · 4h · 2h · 1h · 30m`. Selected chip in lavender `#C8B8DB`.
- **`now_playing_bar.dart`** — `BottomAppBar`-style container, 96px tall (two rows: transport + chips). Shows countdown `mm:ss`/`h:mm` when timer active; countdown text turns lavender during the final 2-min fade.

Tap behavior: tapping a card plays it (replacing current sound — single-sound MVP); tapping the playing card pauses. Long-press or heart toggles favorite.

---

## 5. Audio Engine

### Seamless looping

```dart
final player = AudioPlayer();
await player.setAudioSource(
  AudioSource.asset(sound.assetPath),
  preload: true,
);
await player.setLoopMode(LoopMode.one);   // gapless native looping (ExoPlayer on Android)
player.play();
```

Two-layer defense against stutter:
1. **File-level:** OGG assets with crossfaded loop points (Section 2) — even a few dropped ms is inaudible.
2. **Player-level:** just_audio's `LoopMode.one` uses ExoPlayer's native seamless repeat on Android — no Dart-side seek-to-zero hack (never do `onComplete → seek(0)`, that stutters).

Verify tonight: play brown noise for 3+ minutes with headphones; any tick means the file needs a longer crossfade.

### Fade-out attenuator (2 min)

In `timer_service.dart`:

```dart
void _tick() {
  remaining -= 1s;
  if (remaining.inSeconds <= 120) {
    audio.setVolume(Curves.easeOut.transform(remaining.inSeconds / 120));
  }
  if (remaining <= Duration.zero) { audio.stop(); audio.setVolume(1.0); cancel(); }
}
```

`easeOut` curve sounds more natural than linear at low volumes. `setVolume` on just_audio is cheap; 1Hz updates are smooth enough (bump to 250ms ticks in final 2 min if steps are audible).

### Background playback (critical for a sleep app)

- `audio_service` `AudioHandler` wrapping the player → Android foreground service + media notification.
- `AndroidManifest.xml`: `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK` permissions; register `com.ryanheise.audioservice.AudioService` per audio_service README.
- `audio_session`: configure as `AudioSessionConfiguration.music()` so it ducks/pauses correctly for calls.

### Future multi-sound mixing (design for it, don't build it)

`NatureAudioService` internally holds `Map<String, AudioPlayer>` keyed by sound id, even though MVP enforces `maxConcurrent = 1`. API is already `playSound(id)` / `stopSound(id)` / `setSoundVolume(id, v)` — later, mixing = removing the "stop others first" line and adding per-card volume sliders. Zero refactor cost.

---

## 6. CI/CD — GitHub Actions

`.github/workflows/build-apk.yml`:

```yaml
name: Build APK
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze --no-fatal-infos
      - run: flutter build apk --release --target-platform android-arm64
      - uses: actions/upload-artifact@v4
        with:
          name: nature-sounds-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 14
```

Notes:
- **Signing:** release builds use the auto-generated debug signing config by default when no keystore is set — fine for sideloading. Ensure `android/app/build.gradle` has `signingConfig signingConfigs.debug` under `release` (Flutter's default template already does). **No secrets needed → safe for public repo.**
- `--target-platform android-arm64` → single smaller APK, Pixel 8 is arm64.
- Download path tomorrow: repo → Actions → latest run → Artifacts → `nature-sounds-apk` → unzip → install on Pixel 8 (enable "install unknown apps").
- Optional 10-min upgrade: add a `release` job that attaches the APK to a GitHub Release on tag push — nicer download link, do it only if ahead of schedule.

---

## 7. Task Breakdown (ordered, ~7 hrs total)

| # | Task | Time | Done when |
|---|---|---|---|
| 1 | `flutter create nature_sounds`, init git, push to public GitHub repo, add MIT LICENSE. Set `minSdkVersion 24`, app name/label "Nature Sounds". | 20 min | Repo public, app runs blank on Pixel 8 via USB |
| 2 | **CI first:** add `build-apk.yml`, push, confirm green build + artifact downloads. (Do this before writing app code — de-risks tomorrow's deliverable.) | 30 min | APK artifact downloadable |
| 3 | Write `tools/generate_noise.py`; generate brown/white/pink/fan/wind OGGs with crossfaded loop points. | 45 min | 5 synthetic sounds, verified seamless in a media player |
| 4 | Source 11 CC0 sounds from Pixabay/Freesound; batch: trim, loop-crossfade, normalize, OGG export. Write `CREDITS.md`. Add all to `pubspec.yaml` assets. | 60 min | 16 assets < 25MB total |
| 5 | Add packages; build `sound.dart` catalog, `app_theme.dart` with palette from §4, `app.dart` shell. | 30 min | Themed empty scaffold runs |
| 6 | `audio_service.dart` + `audio_session` + `audio_service` AudioHandler + manifest changes. Hardcode-play one sound; verify loop is seamless and survives screen-off for 5 min with media notification. | 60 min | Background gapless playback works on Pixel 8 |
| 7 | `app_state.dart` + `prefs_service.dart` (favorites/recents load/save). Wire Provider in `main.dart`. | 30 min | State toggles persist across restart |
| 8 | UI: `home_screen.dart` grid + `sound_card.dart` with playing state and heart toggle. Tap-to-play wired to audio service; recents update on play. | 60 min | Full grid plays/pauses/favorites |
| 9 | `timer_service.dart` + `duration_selector.dart` + `now_playing_bar.dart` with countdown and 2-min ease-out fade. Test with a debug 3-min duration. | 50 min | Timer counts down, fades, stops, volume resets |
| 10 | Favorites + Recents horizontal sections on home screen (hide when empty). | 30 min | Sections appear/update live |
| 11 | Polish pass: app icon (simple flat wave glyph via `flutter_launcher_icons`, teal on `#1A2027`), splash background color, README with screenshot + install instructions. | 30 min | Looks intentional |
| 12 | Full device test on Pixel 8: seamless loops (headphones, 3 min each on 3–4 sounds), screen off 10 min, timer fade, kill/restart persistence. Fix, push, verify final CI artifact. | 45 min | **Ship it** |

**Cut list if running late** (in order): task 11 icon → recents section → pulse animation → drop to 10 sounds. **Never cut:** task 2 (CI), task 6 (background audio), loop verification.
