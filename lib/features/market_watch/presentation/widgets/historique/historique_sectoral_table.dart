import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// ULTIMATE Sectoral Table — Smooth AnimatedSize, premium expandable cards,
/// color-coded leading accent, glow effects, polished detail section
class HistoriqueSectoralTable extends StatefulWidget {
  final List<SectorBreakdown> sectors;

  const HistoriqueSectoralTable({super.key, required this.sectors});

  @override
  State<HistoriqueSectoralTable> createState() =>
      _HistoriqueSectoralTableState();
}

class _HistoriqueSectoralTableState extends State<HistoriqueSectoralTable> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_tree_rounded,
                        size: 16, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text('Répartition Sectorielle',
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '${widget.sectors.length} secteurs',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Gradient divider ──
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.divider30,
                  Colors.transparent,
                ]),
              ),
            ),

            // ── Sector rows ──
            ...widget.sectors.asMap().entries.map((entry) {
              final idx = entry.key;
              final sector = entry.value;
              final isExpanded = _expandedIndex == idx;
              return _SectorRow(
                sector: sector,
                isExpanded: isExpanded,
                isLast: idx == widget.sectors.length - 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedIndex = isExpanded ? null : idx;
                  });
                },
              )
                  .animate()
                  .fadeIn(delay: (50 + idx * 35).ms, duration: 350.ms);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectorRow extends StatelessWidget {
  final SectorBreakdown sector;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _SectorRow({
    required this.sector,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = sector.variation >= 0;
    final varColor = isPositive ? AppColors.bullGreen : AppColors.bearRed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        color: isExpanded
            ? AppColors.primaryBlue.withValues(alpha: 0.03)
            : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Row(
                children: [
                  // Color accent bar
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          varColor,
                          varColor.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sector.name,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${sector.nbSocietes} sociétés',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Percentage + variation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${sector.percentage.toStringAsFixed(1)}%',
                        style: AppTypography.bodyMediumBold,
                      ),
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: varColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.north_east_rounded
                                  : Icons.south_east_rounded,
                              size: 10,
                              color: varColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${isPositive ? '+' : ''}${sector.variation.toStringAsFixed(2)}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: varColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  // Animated arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: isExpanded
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Smooth height expand with AnimatedSize
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? _ExpandedDetails(sector: sector)
                  : const SizedBox.shrink(),
            ),

            if (!isLast)
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 33),
                color: AppColors.divider30,
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final SectorBreakdown sector;

  const _ExpandedDetails({required this.sector});

  @override
  Widget build(BuildContext context) {
    final isPositive = sector.variation >= 0;
    final varColor = isPositive ? AppColors.bullGreen : AppColors.bearRed;

    return Container(
      margin: const EdgeInsets.fromLTRB(33, 0, 18, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider30),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.donut_large_rounded,
            label: 'Part du marché',
            value: '${sector.percentage.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.trending_up_rounded,
            label: 'Variation',
            value: '${isPositive ? '+' : ''}${sector.variation.toStringAsFixed(2)}%',
            valueColor: varColor,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.business_rounded,
            label: 'Sociétés cotées',
            value: '${sector.nbSocietes}',
          ),
          const SizedBox(height: 12),
          // Visual gradient bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (sector.percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryBlueLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.labelMedium),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMediumBold.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
