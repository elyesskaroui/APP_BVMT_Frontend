import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/historique_bloc.dart';
import '../bloc/historique_event.dart';
import '../bloc/historique_state.dart';
import 'historique/historique_breakdown_card.dart';
import 'historique/historique_date_picker.dart';
import 'historique/historique_evolution_chart.dart';
import 'historique/historique_index_card.dart';
import 'historique/historique_kpi_dashboard.dart';
import 'historique/historique_market_indicators.dart';
import 'historique/historique_sectoral_chart.dart';
import 'historique/historique_sectoral_table.dart';

/// ULTIMATE Main Content Orchestrator — Premium staggered entrance,
/// section dividers, refined shimmer skeleton, polished error state
class MwHistoriqueContent extends StatelessWidget {
  const MwHistoriqueContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoriqueBloc, HistoriqueState>(
      builder: (context, state) {
        if (state is HistoriqueLoading || state is HistoriqueInitial) {
          return _buildShimmer();
        }
        if (state is HistoriqueError) {
          return _buildError(context, state.message);
        }
        if (state is HistoriqueLoaded) {
          return _buildLoaded(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(BuildContext context, HistoriqueLoaded state) {
    final session = state.selectedSession;
    if (session == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppColors.primaryBlue.withValues(alpha: 0.3), size: 48),
              const SizedBox(height: 12),
              Text(
                'Aucune séance disponible',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredChart = state.filteredChartData;
    const gap = SizedBox(height: 16);
    int delay = 0;
    const delayStep = 50;

    Widget stagger(Widget child) {
      final d = delay;
      delay += delayStep;
      return child
          .animate()
          .fadeIn(duration: 450.ms, delay: Duration(milliseconds: d))
          .slideY(
              begin: 0.025,
              end: 0,
              duration: 450.ms,
              delay: Duration(milliseconds: d),
              curve: Curves.easeOutCubic);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 1 — Section Title
        stagger(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.12),
                        AppColors.primaryBlue.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.primaryBlue,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Physionomie Boursière',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Decorative dot trio
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue
                            .withValues(alpha: 0.15 + i * 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        gap,

        // 2 — Date Picker
        stagger(
          HistoriqueDatePicker(
            selectedDate: state.selectedDate,
            latestDate: state.sessions.isNotEmpty
                ? state.sessions.first.date
                : null,
            onDateSelected: (d) {
              context.read<HistoriqueBloc>().add(HistoriqueDateChanged(d));
            },
          ),
        ),
        gap,

        // 3 — KPI Dashboard
        stagger(HistoriqueKpiDashboard(session: session)),
        gap,

        // 4 — Market Indicators
        stagger(HistoriqueMarketIndicators(session: session)),
        gap,

        // 5 — Index Cards side by side
        stagger(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: HistoriqueIndexCard(
                    title: 'TUNINDEX',
                    currentValue: session.tunindexValue,
                    change: session.tunindexChange,
                    chartData: filteredChart,
                    isTunindex20: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HistoriqueIndexCard(
                    title: 'TUNINDEX20',
                    currentValue: session.tunindex20Value,
                    change: session.tunindex20Change,
                    chartData: filteredChart,
                    isTunindex20: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        gap,

        // ── Section divider ──
        _sectionDivider(),

        // 6 — Evolution Chart
        stagger(
          HistoriqueEvolutionChart(
            chartData: filteredChart,
            selectedPeriod: state.selectedPeriod,
            showTunindex20: state.showTunindex20,
            onPeriodChanged: (p) {
              context.read<HistoriqueBloc>().add(HistoriquePeriodChanged(p));
            },
            onToggleTunindex20: () {
              context
                  .read<HistoriqueBloc>()
                  .add(const HistoriqueToggleTunindex20());
            },
          ),
        ),
        gap,

        // 7 — Breakdown Card
        stagger(HistoriqueBreakdownCard(session: session)),
        gap,

        // ── Section divider ──
        if (state.sectorBreakdowns.isNotEmpty) _sectionDivider(),

        // 8 — Sectoral Table
        if (state.sectorBreakdowns.isNotEmpty) ...[
          stagger(HistoriqueSectoralTable(sectors: state.sectorBreakdowns)),
          gap,
        ],

        // 9 — Sectoral Chart
        if (state.sectorBreakdowns.isNotEmpty) ...[
          stagger(HistoriqueSectoralChart(sectors: state.sectorBreakdowns)),
          gap,
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.primaryBlue.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EAF0),
      highlightColor: const Color(0xFFF5F6FA),
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Date picker
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 16),
            // KPI grid
            Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Container(
                    height: 82,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Container(
                    height: 82,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Market indicators
            Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            const SizedBox(height: 16),
            // Index cards
            Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Container(
                    height: 130,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chart
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            const SizedBox(height: 16),
            // Breakdown
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bearRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.bearRed, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Oups !',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context
                    .read<HistoriqueBloc>()
                    .add(const HistoriqueLoadRequested());
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
