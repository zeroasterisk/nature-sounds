import 'package:flutter/material.dart';

enum SoundCategory { nature, weather, ambient, noise }

class Sound {
  final String id;
  final String name;
  final IconData icon;
  final String assetPath;
  final SoundCategory category;

  const Sound({
    required this.id,
    required this.name,
    required this.icon,
    required this.assetPath,
    required this.category,
  });

  /// The full catalog of available sounds.
  static const List<Sound> catalog = [
    // Nature
    Sound(
      id: 'waves',
      name: 'Ocean Waves',
      icon: Icons.waves,
      assetPath: 'assets/sounds/waves.ogg',
      category: SoundCategory.nature,
    ),
    Sound(
      id: 'forest',
      name: 'Forest',
      icon: Icons.forest,
      assetPath: 'assets/sounds/forest.ogg',
      category: SoundCategory.nature,
    ),
    Sound(
      id: 'birds',
      name: 'Birds',
      icon: Icons.flutter_dash,
      assetPath: 'assets/sounds/birds.ogg',
      category: SoundCategory.nature,
    ),
    Sound(
      id: 'crickets',
      name: 'Crickets',
      icon: Icons.nights_stay,
      assetPath: 'assets/sounds/crickets.ogg',
      category: SoundCategory.nature,
    ),
    Sound(
      id: 'locusts',
      name: 'Locusts',
      icon: Icons.grass,
      assetPath: 'assets/sounds/locusts.ogg',
      category: SoundCategory.nature,
    ),

    // Weather
    Sound(
      id: 'rain',
      name: 'Rain',
      icon: Icons.water_drop,
      assetPath: 'assets/sounds/rain.ogg',
      category: SoundCategory.weather,
    ),
    Sound(
      id: 'heavy_rain',
      name: 'Heavy Rain',
      icon: Icons.thunderstorm,
      assetPath: 'assets/sounds/heavy_rain.ogg',
      category: SoundCategory.weather,
    ),
    Sound(
      id: 'thunder',
      name: 'Thunder',
      icon: Icons.bolt,
      assetPath: 'assets/sounds/thunder.ogg',
      category: SoundCategory.weather,
    ),
    Sound(
      id: 'wind',
      name: 'Wind',
      icon: Icons.air,
      assetPath: 'assets/sounds/wind.ogg',
      category: SoundCategory.weather,
    ),

    // Ambient
    Sound(
      id: 'campfire',
      name: 'Campfire',
      icon: Icons.local_fire_department,
      assetPath: 'assets/sounds/campfire.ogg',
      category: SoundCategory.ambient,
    ),
    Sound(
      id: 'river',
      name: 'River',
      icon: Icons.water,
      assetPath: 'assets/sounds/river.ogg',
      category: SoundCategory.ambient,
    ),
    Sound(
      id: 'stream',
      name: 'Stream',
      icon: Icons.stream,
      assetPath: 'assets/sounds/stream.ogg',
      category: SoundCategory.ambient,
    ),
    Sound(
      id: 'fan',
      name: 'Fan',
      icon: Icons.toys,
      assetPath: 'assets/sounds/fan.ogg',
      category: SoundCategory.ambient,
    ),

    // Noise
    Sound(
      id: 'brown_noise',
      name: 'Brown Noise',
      icon: Icons.graphic_eq,
      assetPath: 'assets/sounds/brown_noise.ogg',
      category: SoundCategory.noise,
    ),
    Sound(
      id: 'white_noise',
      name: 'White Noise',
      icon: Icons.equalizer,
      assetPath: 'assets/sounds/white_noise.ogg',
      category: SoundCategory.noise,
    ),
    Sound(
      id: 'pink_noise',
      name: 'Pink Noise',
      icon: Icons.bar_chart,
      assetPath: 'assets/sounds/pink_noise.ogg',
      category: SoundCategory.noise,
    ),
  ];

  /// Look up a sound by its id.
  static Sound? findById(String id) {
    try {
      return catalog.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
