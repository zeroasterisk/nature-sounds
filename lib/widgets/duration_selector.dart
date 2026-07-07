import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: SleepDuration.values.map((d) {
              final isSelected = state.selectedDuration == d;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(d.label),
                  selected: isSelected,
                  onSelected: (_) => state.setDuration(d),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                  backgroundColor: AppTheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textSubtitle,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isSelected
                        ? const BorderSide(color: AppTheme.primary, width: 1)
                        : BorderSide.none,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
