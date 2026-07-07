import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sound.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sound_card.dart';
import '../widgets/duration_selector.dart';
import '../widgets/now_playing_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nature Sounds'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    // Favorites section
                    if (state.favoriteIds.isNotEmpty) ...[
                      _SectionHeader(title: 'Favorites', icon: Icons.favorite),
                      _HorizontalSoundList(
                        soundIds: state.favoriteIds,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recents section
                    if (state.recentIds.isNotEmpty) ...[
                      _SectionHeader(
                          title: 'Recently Played', icon: Icons.history),
                      _HorizontalSoundList(
                        soundIds: state.recentIds,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Duration selector
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: DurationSelector(),
                    ),

                    // All sounds grid
                    const _SectionHeader(title: 'All Sounds', icon: Icons.music_note),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: Sound.catalog.length,
                        itemBuilder: (context, index) {
                          return SoundCard(sound: Sound.catalog[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Now playing bar
              const NowPlayingBar(),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSubtitle),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalSoundList extends StatelessWidget {
  final List<String> soundIds;

  const _HorizontalSoundList({required this.soundIds});

  @override
  Widget build(BuildContext context) {
    final sounds = soundIds
        .map((id) => Sound.findById(id))
        .where((s) => s != null)
        .cast<Sound>()
        .toList();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          return SoundCard(sound: sounds[index], compact: true);
        },
      ),
    );
  }
}
