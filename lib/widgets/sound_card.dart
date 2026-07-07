import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sound.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SoundCard extends StatelessWidget {
  final Sound sound;
  final bool compact;

  const SoundCard({super.key, required this.sound, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isCurrentlyPlaying =
            state.isPlaying && state.currentSound?.id == sound.id;
        final isFav = state.isFavorite(sound.id);

        if (compact) {
          return _buildCompact(context, state, isCurrentlyPlaying, isFav);
        }
        return _buildFull(context, state, isCurrentlyPlaying, isFav);
      },
    );
  }

  /// Full-size card for the main grid.
  Widget _buildFull(
    BuildContext context,
    AppState state,
    bool isCurrentlyPlaying,
    bool isFav,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentlyPlaying
            ? const BorderSide(color: AppTheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isCurrentlyPlaying) {
            state.stopPlayback();
          } else {
            state.playSoundById(sound.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Favorite button top-right
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => state.toggleFavorite(sound.id),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.favoriteHeart : AppTheme.textSubtitle,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              _PlayingIcon(
                icon: sound.icon,
                isPlaying: isCurrentlyPlaying,
              ),
              const SizedBox(height: 8),
              Text(
                sound.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact horizontal pill for favorites / recents rows.
  Widget _buildCompact(
    BuildContext context,
    AppState state,
    bool isCurrentlyPlaying,
    bool isFav,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentlyPlaying
            ? const BorderSide(color: AppTheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isCurrentlyPlaying) {
            state.stopPlayback();
          } else {
            state.playSoundById(sound.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sound.icon, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                sound.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon that shows a subtle pulse animation when the sound is playing.
class _PlayingIcon extends StatefulWidget {
  final IconData icon;
  final bool isPlaying;

  const _PlayingIcon({required this.icon, required this.isPlaying});

  @override
  State<_PlayingIcon> createState() => _PlayingIconState();
}

class _PlayingIconState extends State<_PlayingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PlayingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.isPlaying ? _scale : const AlwaysStoppedAnimation(1.0),
      child: Icon(
        widget.icon,
        size: 40,
        color: widget.isPlaying ? AppTheme.primary : AppTheme.textSubtitle,
      ),
    );
  }
}
