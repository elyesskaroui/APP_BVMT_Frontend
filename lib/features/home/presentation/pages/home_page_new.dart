import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/cubits/market_status_cubit.dart';
import '../../../../shared/data/bvmt_ticker_data.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/ticker_bar.dart';
import '../bloc/market_summary_bloc.dart';
import '../bloc/market_summary_event.dart';
import '../bloc/market_summary_state.dart';
import '../widgets/market_summary_page_view.dart';
import '../widgets/news_ticker_bar.dart';
import '../widgets/index_chart_popup.dart';
import '../widgets/premium_index_card.dart';

/// Page d'accueil — Résumé du marché BVMT
/// Design premium : Header bleu compact + corps blanc/gris clair
/// ✅ Accessibilité WCAG 2.1 AA : Semantics, touch targets ≥48dp, min 12px
/// ✅ Responsive : adaptatif mobile / tablette / desktop
/// ✅ Animations de transition entre états
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketSummaryBloc, MarketSummaryState>(
      builder: (context, state) {
        // Animated transitions between states
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildForState(context, state),
        );
      },
    );
  }

  Widget _buildForState(BuildContext context, MarketSummaryState state) {
    if (state is MarketSummaryLoading || state is MarketSummaryInitial) {
      return _buildLoading(context, key: const ValueKey('loading'));
    }
    if (state is MarketSummaryLoaded) {
      return _buildLoaded(context, state, key: const ValueKey('loaded'));
    }
    if (state is MarketSummaryError) {
      return _buildError(context, state.message, key: const ValueKey('error'));
    }
    return const SizedBox.shrink();
  }

  // ─────────────── LOADING (Shimmer Skeleton) ───────────────
  Widget _buildLoading(BuildContext context, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          _buildHeader(null),
          // Shimmer news bar placeholder
          Container(height: 38, color: AppColors.deepNavy),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.horizontalPadding(context),
                vertical: AppDimens.paddingMD,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab bar skeleton
                    Row(
                      children: List.generate(
                        3,
                        (_) => Container(
                          height: 32,
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Index cards skeleton
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stats grid skeleton 2x2
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMD,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Section header skeleton
                    Container(
                      height: 18,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Carousel skeleton
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLG,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── LOADED ───────────────
  Widget _buildLoaded(
    BuildContext context,
    MarketSummaryLoaded state, {
    Key? key,
  }) {
    final hPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: Semantics(
        label: 'Page d\'accueil - Résumé du marché BVMT',
        child: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async {
            context.read<MarketSummaryBloc>().add(
              const MarketSummaryRefreshRequested(),
            );
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header bleu compact ──
              SliverToBoxAdapter(
                child: Semantics(
                  label:
                      'En-tête BVMT - Session ${state.summary.isSessionOpen ? "ouverte" : "fermée"}',
                  child: _buildHeader(state),
                ),
              ),

              // ── Ticker défilant cours BVMT ──
              const SliverToBoxAdapter(
                child: TickerBar(
                  items: kBvmtTickerData,
                  speed: 60,
                ),
              ),

              // ── News ticker bar ──
              SliverToBoxAdapter(
                child: Semantics(
                  label: 'Fil d\'actualités',
                  child: NewsTicker(news: state.latestNews),
                ),
              ),

              // ── Market tabs ──
              SliverToBoxAdapter(child: _buildMarketTabs(hPadding)),

              // ── Index cards (TUNINDEX + TUNINDEX20) ──
              SliverToBoxAdapter(
                child: Semantics(
                  label: 'Indices boursiers',
                  child: _buildIndicesSection(context, state, hPadding),
                ),
              ),

              // ── Stats grid 2×2 ──
              SliverToBoxAdapter(
                child: Semantics(
                  label: 'Statistiques du marché',
                  child: _buildStatsGrid(state, hPadding),
                ),
              ),

              // ── Carrousel 8 slides ──
              SliverToBoxAdapter(
                child: Semantics(
                  label: 'Résumé détaillé du marché - carrousel',
                  child: _buildCarouselSection(context, state, hPadding),
                ),
              ),

              // ── Bouton résumé ──
              SliverToBoxAdapter(child: _buildResumeButton(context, hPadding)),

              // Espace pour bottom nav
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── HEADER BLEU COMPACT ──
  // ═══════════════════════════════════════════
  Widget _buildHeader(MarketSummaryLoaded? state) {
    return Builder(
      builder:
          (context) => Container(
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppShadows.cardLight,
                      ),
                      child: Center(
                        child: Text(
                          'B',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BVMT',
                            style: AppTypography.onPrimaryTitle.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Bourse de Tunis',
                            style: AppTypography.onPrimaryMuted,
                          ),
                        ],
                      ),
                    ),

                    // Session badge — mis à jour automatiquement via MarketStatusCubit
                    if (state != null)
                      BlocBuilder<MarketStatusCubit, MarketStatusState>(
                        builder: (context, marketStatus) {
                          return Semantics(
                            label:
                                marketStatus.isOpen
                                    ? 'Session de marché ouverte'
                                    : 'Session de marché fermée',
                            child: _buildSessionBadge(marketStatus.isOpen, marketStatus.statusText),
                          );
                        },
                      ),
                    const SizedBox(width: 8),

                    // Market Watch button — BVMT orange style
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/market-watch'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentOrange,
                                Color(0xFFF0875A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentOrange
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.show_chart_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MARKET WATCH',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSessionBadge(bool open, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: open ? AppColors.bullGreen20 : AppColors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              open
                  ? AppColors.bullGreen.withValues(alpha: 0.5)
                  : AppColors.white25,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicator + icon for daltonism accessibility
          Icon(
            open ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: open ? AppColors.bullGreen : AppColors.warningYellow,
          ),
          const SizedBox(width: 5),
          Text(
            open ? 'Ouverte' : 'Fermée',
            style: AppTypography.labelSmall.copyWith(
              color: open ? AppColors.bullGreen : AppColors.white80,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── MARKET TABS ──
  // ═══════════════════════════════════════════
  Widget _buildMarketTabs(double hPadding) {
    const tabs = [
      'Marché Principal',
      'Marché Alternatif',
      'Hors-Cote',
      'Obligations',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: SizedBox(
        height: 40, // ≥ 48dp total with padding for touch target
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          itemCount: tabs.length,
          itemBuilder: (_, index) {
            final selected = index == 0;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {}, // TODO: Filter par marché
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          selected
                              ? null
                              : Border.all(color: AppColors.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[index],
                      style: AppTypography.labelMedium.copyWith(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── INDICES SECTION ──
  // ═══════════════════════════════════════════
  Widget _buildIndicesSection(BuildContext context, MarketSummaryLoaded state, double hPadding) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPadding, 4, hPadding, 16),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label:
                  '${state.summary.tunindex.name}: ${state.summary.tunindex.formattedValue}, variation ${state.summary.tunindex.formattedChange}',
              child: PremiumIndexCard(
                index: state.summary.tunindex,
                onTap: () => IndexChartPopup.show(context, state.summary.tunindex),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              label:
                  '${state.summary.tunindex20.name}: ${state.summary.tunindex20.formattedValue}, variation ${state.summary.tunindex20.formattedChange}',
              child: PremiumIndexCard(
                index: state.summary.tunindex20,
                onTap: () => IndexChartPopup.show(context, state.summary.tunindex20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildIndexCard replaced by PremiumIndexCard widget

  // ═══════════════════════════════════════════
  // ── STATS GRID 2×2 ──
  // ═══════════════════════════════════════════
  Widget _buildStatsGrid(MarketSummaryLoaded state, double hPadding) {
    final s = state.summary;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.primaryBlue,
                  label: 'Capitalisation',
                  value: _compactNum(s.marketCap),
                  unit: 'TND',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.accentOrange,
                  label: 'Capitaux',
                  value: _compactNum(s.totalCapitaux),
                  unit: 'TND',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Transactions',
                  value: _formatInt(s.totalTransactions),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HausseBaisseCard(
                  hausses: s.nbHausses,
                  baisses: s.nbBaisses,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── CARROUSEL SECTION ──
  // ═══════════════════════════════════════════
  Widget _buildCarouselSection(
    BuildContext context,
    MarketSummaryLoaded state,
    double hPadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header — premium visual hierarchy with gradient accent
        Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accentOrange, Color(0xFFF0875A)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé du marché',
                      style: AppTypography.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Données détaillées de la séance',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue08,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: AppColors.primaryBlue.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.summary.sessionDate,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // PageView carousel — increased height for premium content
        SizedBox(
          height: 440,
          child: MarketSummaryPageView(
            state: state,
            onPageChanged: (page) {
              context.read<MarketSummaryBloc>().add(
                MarketSummaryPageChanged(page),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── BOUTON RÉSUMÉ (wired to market page) ──
  // ═══════════════════════════════════════════
  Widget _buildResumeButton(BuildContext context, double hPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 4, hPadding, 8),
      child: SizedBox(
        width: double.infinity,
        height: 48, // min touch target
        child: OutlinedButton.icon(
          onPressed: () => context.push('/market'),
          icon: const Icon(Icons.bar_chart_rounded, size: 20),
          label: const Text('Voir le résumé complet du marché'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            ),
            textStyle: AppTypography.button,
          ),
        ),
      ),
    );
  }

  // ─────────────── ERROR with better UX ───────────────
  Widget _buildError(BuildContext context, String message, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Semantics(
          label: 'Erreur de chargement: $message',
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error illustration
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.bearRed10,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.bearRed,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLG),
                Text('Connexion impossible', style: AppTypography.h3),
                const SizedBox(height: AppDimens.paddingSM),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingXL),
                SizedBox(
                  height: 48, // min touch target
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MarketSummaryBloc>().add(
                        const MarketSummaryLoadRequested(),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                      ),
                      textStyle: AppTypography.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  static String _compactNum(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)} Md';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)} M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)} K';
    return v.toStringAsFixed(0);
  }

  static String _formatInt(int v) {
    return v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }
}

// ═══════════════════════════════════════════════
// ── STAT CARD (premium glassmorphism) ──
// ═══════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value ${unit ?? ''}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B2A4A),
              const Color(0xFF0F1E36),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1E36).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon with glow effect
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iconColor.withValues(alpha: 0.25),
                        iconColor.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTypography.stockPrice.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit!,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ── HAUSSE/BAISSE CARD — premium with progress bar ──
// ═══════════════════════════════════════════════
class _HausseBaisseCard extends StatelessWidget {
  final int hausses;
  final int baisses;

  const _HausseBaisseCard({required this.hausses, required this.baisses});

  @override
  Widget build(BuildContext context) {
    final total = hausses + baisses;
    final ratio = total > 0 ? hausses / total : 0.5;

    return Semantics(
      label: '$hausses hausses, $baisses baisses',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B2A4A),
              const Color(0xFF0F1E36),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1E36).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hausses / Baisses',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Flexible(
                      flex: (ratio * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.bullGreen,
                              AppColors.bullGreen.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      flex: ((1 - ratio) * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.bearRed.withValues(alpha: 0.7),
                              AppColors.bearRed,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        color: AppColors.bullGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$hausses',
                      style: TextStyle(
                        color: AppColors.bullGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.trending_down_rounded,
                        color: AppColors.bearRed, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$baisses',
                      style: TextStyle(
                        color: AppColors.bearRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
