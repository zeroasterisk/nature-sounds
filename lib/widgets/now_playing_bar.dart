import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sound = state.currentSound;
        if (sound == null || !state.isPlaying) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(
                color: AppTheme.primary,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Icon(sound.icon, color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sound.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.remainingLabel.isNotEmpty)
                        Text(
                          state.remainingLabel,
                          style: TextStyle(
                            color: state.isFading
                                ? AppTheme.timerLavender
                                : AppTheme.textSubtitle,
                            fontSize: 12,
                            fontWeight: state.isFading
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, size: 36),
                  color: AppTheme.textSubtitle,
                  onPressed: () => state.stopPlayback(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
