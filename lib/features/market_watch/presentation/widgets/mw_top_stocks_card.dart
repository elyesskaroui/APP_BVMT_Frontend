import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../home/domain/entities/market_summary_entity.dart';
import 'mw_session_header.dart';
import 'mw_stock_row.dart';

/// Card réutilisable pour un classement (Top Hausses, Baisses, Capitaux, etc.)
/// Design premium avec accent coloré, staggered animations et lignes cliquables
class MwTopStocksCard extends StatefulWidget {
  final String title;
  final String sessionDate;
  final bool isOpen;
  final List<TopStockEntry> entries;
  final String metricColumnHeader;
  final int maxVisible;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final Color? accentColor;

  const MwTopStocksCard({
    super.key,
    required this.title,
    required this.sessionDate,
    required this.isOpen,
    required this.entries,
    this.metricColumnHeader = 'CAPITAUX',
    this.maxVisible = 5,
    this.expanded = false,
    this.onToggleExpand,
    this.accentColor,
  });

  Color get resolvedAccent {
    if (accentColor != null) return accentColor!;
    final t = title.toUpperCase();
    if (t.contains('HAUSSE')) return AppColors.bullGreen;
    if (t.contains('BAISSE')) return AppColors.bearRed;
    if (t.contains('CAPITAUX')) return const Color(0xFFF39C12);
    if (t.contains('QUANTIT')) return AppColors.primaryBlue;
    if (t.contains('TRANSACTION')) return const Color(0xFF9B59B6);
    return AppColors.primaryBlue;
  }

  @override
  State<MwTopStocksCard> createState() => _MwTopStocksCardState();
}

class _MwTopStocksCardState extends State<MwTopStocksCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant MwTopStocksCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _staggerCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.resolvedAccent;
    final visibleEntries = widget.expanded
        ? widget.entries
        : widget.entries.take(widget.maxVisible).toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top accent bar ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent,
                  accent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: MwSessionHeader(
              title: widget.title,
              sessionDate: widget.sessionDate,
              isOpen: widget.isOpen,
              accentColor: accent,
            ),
          ),

          // ── Column headers ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              border: Border(
                top: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.4),
                    width: 0.5),
                bottom: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.4),
                    width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  flex: 3,
                  child: Text('VALEUR', style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DERNIER',
                      textAlign: TextAlign.right, style: _headerStyle),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Text('VAR %',
                      textAlign: TextAlign.center, style: _headerStyle),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.metricColumnHeader,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: _headerStyle,
                  ),
                ),
              ],
            ),
          ),

          // ── Stock rows with staggered animation ──
          ...visibleEntries.asMap().entries.map((e) {
            final index = e.key;
            final entry = e.value;
            final delay = index / (visibleEntries.length + 1).clamp(1, 20);
            final end = (delay + 0.6).clamp(0.0, 1.0);
            final animation = CurvedAnimation(
              parent: _staggerCtrl,
              curve: Interval(delay, end, curve: Curves.easeOutCubic),
            );
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Transform.translate(
                offset: Offset(30 * (1 - animation.value), 0),
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              ),
              child: MwStockRow(
                entry: entry,
                rank: index + 1,
                onTap: () => context.push('/stock/${entry.symbol}'),
              ),
            );
          }),

          // ── Voir plus / moins ──
          if (widget.entries.length > widget.maxVisible)
            InkWell(
              onTap: widget.onToggleExpand,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: accent,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.expanded ? 'Voir moins' : 'Voir tout',
                            style: AppTypography.labelSmall.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
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

  TextStyle get _headerStyle => AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        fontSize: 9,
        letterSpacing: 0.8,
      );
}
