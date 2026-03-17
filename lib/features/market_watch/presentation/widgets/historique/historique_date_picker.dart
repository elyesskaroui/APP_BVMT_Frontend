import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

/// ULTIMATE Date Picker — Premium glassmorphism, pulsing live dot,
/// prev/next day arrows, animated border, haptic feedback
class HistoriqueDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? latestDate;
  final ValueChanged<DateTime> onDateSelected;

  const HistoriqueDatePicker({
    super.key,
    this.selectedDate,
    this.latestDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = selectedDate ?? latestDate ?? DateTime.now();
    final dayName = DateFormat('EEEE', 'fr_FR').format(displayDate);
    final dayNum = DateFormat('d MMMM yyyy', 'fr_FR').format(displayDate);
    final isLatest = latestDate != null &&
        displayDate.year == latestDate!.year &&
        displayDate.month == latestDate!.month &&
        displayDate.day == latestDate!.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.07),
                  AppColors.primaryBlue.withValues(alpha: 0.02),
                  AppColors.primaryBlue.withValues(alpha: 0.05),
                ],
                stops: const [0, 0.5, 1],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Previous day button ──
                _NavArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _navigateDay(displayDate, -1),
                ),

                // ── Main date area (tappable for calendar) ──
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDatePicker(context, displayDate),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          // Calendar icon with radial glow
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primaryBlue.withValues(alpha: 0.15),
                                  AppColors.primaryBlue.withValues(alpha: 0.02),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 19,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Séance du',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    if (isLatest) ...[
                                      const SizedBox(width: 6),
                                      // Pulsing "latest" dot
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.bullGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                          .animate(
                                            onPlay: (c) => c.repeat(reverse: true),
                                          )
                                          .scale(
                                            begin: const Offset(1, 1),
                                            end: const Offset(1.4, 1.4),
                                            duration: 1000.ms,
                                          )
                                          .then()
                                          .scale(
                                            begin: const Offset(1.4, 1.4),
                                            end: const Offset(1, 1),
                                            duration: 1000.ms,
                                          ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Dernière',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.bullGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${_capitalize(dayName)} $dayNum',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.unfold_more_rounded,
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Next day button ──
                _NavArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: isLatest ? null : () => _navigateDay(displayDate, 1),
                  enabled: !isLatest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateDay(DateTime current, int direction) {
    var next = current.add(Duration(days: direction));
    // Skip weekends
    while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
      next = next.add(Duration(days: direction));
    }
    if (latestDate != null && next.isAfter(latestDate!)) return;
    if (next.isBefore(DateTime(2024))) return;
    HapticFeedback.selectionClick();
    onDateSelected(next);
  }

  Future<void> _showDatePicker(BuildContext context, DateTime currentDate) async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2024),
      lastDate: latestDate ?? DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      HapticFeedback.mediumImpact();
      onDateSelected(picked);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavArrow({
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
