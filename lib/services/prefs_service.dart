import 'package:shared_preferences/shared_preferences.dart';

/// Persists favorites and recents lists via SharedPreferences.
class PrefsService {
  static const _favoritesKey = 'favorites';
  static const _recentsKey = 'recents';
  static const _maxRecents = 10;

  SharedPreferences? _prefs;

  List<String> _favorites = [];
  List<String> _recents = [];

  List<String> get favorites => List.unmodifiable(_favorites);
  List<String> get recents => List.unmodifiable(_recents);

  /// Must be called once at app startup.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favorites = _prefs!.getStringList(_favoritesKey) ?? [];
    _recents = _prefs!.getStringList(_recentsKey) ?? [];
  }

  bool isFavorite(String soundId) => _favorites.contains(soundId);

  Future<void> toggleFavorite(String soundId) async {
    if (_favorites.contains(soundId)) {
      _favorites.remove(soundId);
    } else {
      _favorites.add(soundId);
    }
    await _prefs?.setStringList(_favoritesKey, _favorites);
  }

  /// Add [soundId] to the front of recents (most recent first).
  /// Removes duplicates and caps at [_maxRecents].
  Future<void> addRecent(String soundId) async {
    _recents.remove(soundId);
    _recents.insert(0, soundId);
    if (_recents.length > _maxRecents) {
      _recents = _recents.sublist(0, _maxRecents);
    }
    await _prefs?.setStringList(_recentsKey, _recents);
  }
}
