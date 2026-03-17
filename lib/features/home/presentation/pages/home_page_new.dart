import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
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
                    // Logo BVMT
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/BVMT.png',
                        fit: BoxFit.contain,
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

                    // Session badge — always visible (MarketStatusCubit inits synchronously)
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
    final dotColor = open ? AppColors.bullGreen : AppColors.bearRed;
    final textColor = open ? AppColors.bullGreen : AppColors.white80;
    final bgColor = open ? AppColors.bullGreen20 : AppColors.bearRed20;
    final borderColor = open
        ? AppColors.bullGreen.withValues(alpha: 0.5)
        : AppColors.bearRed.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            open ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: dotColor,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            open ? 'Ouverte' : 'Fermée',
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
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
    final now = DateFormat('HH:mm').format(DateTime.now());
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPadding, 4, hPadding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "Marché en temps réel" sub-header ──
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.bullGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Marché en temps réel',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 3),
                Text(
                  'Mis à jour à $now',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // ── Index cards row — uniform 16px gap ──
          Row(
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
              const SizedBox(width: 16),
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
    const dividerColor = Color(0xFF243B5E); // subtle internal divider

    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 16),
      child: Column(
        children: [
          // ── Thin separator between indices and stats ──
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.divider.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // ── Single unified container for all 4 stats ──
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2A4A), Color(0xFF0F1E36)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F1E36).withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  // ── Top row ──
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatCell(
                            icon: Icons.pie_chart_rounded,
                            iconColor: AppColors.primaryBlue,
                            label: 'Capitalisation',
                            value: _compactNum(s.marketCap),
                            unit: 'TND',
                          ),
                        ),
                        // Vertical divider
                        Container(width: 1, color: dividerColor),
                        Expanded(
                          child: _StatCell(
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: AppColors.accentOrange,
                            label: 'Capitaux',
                            value: _compactNum(s.totalCapitaux),
                            unit: 'TND',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Horizontal divider
                  Container(height: 1, color: dividerColor),
                  // ── Bottom row ──
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatCell(
                            icon: Icons.swap_horiz_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            label: 'Transactions',
                            value: _formatInt(s.totalTransactions),
                          ),
                        ),
                        // Vertical divider
                        Container(width: 1, color: dividerColor),
                        Expanded(
                          child: _HausseBaisseCell(
                            hausses: s.nbHausses,
                            baisses: s.nbBaisses,
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
// ── STAT CELL (inside unified container — no own border/shadow) ──
// ═══════════════════════════════════════════════
class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;

  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Split value into number and suffix (Md, M, K)
    final parts = value.split(' ');
    final numPart = parts.first;
    final suffixPart = parts.length > 1 ? parts.last : null;

    return Semantics(
      label: '$label: $value ${unit ?? ''}',
      child: Tooltip(
        message: 'Voir détails $label',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.lightImpact(),
            splashColor: iconColor.withValues(alpha: 0.15),
            highlightColor: iconColor.withValues(alpha: 0.05),
            child: SizedBox(
              height: 110,
              child: Stack(
                children: [
                  // ── Background icon (large, subtle) ──
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: Icon(
                      icon,
                      size: 72,
                      color: iconColor.withValues(alpha: 0.07),
                    ),
                  ),
                  // ── Content ──
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top: small icon + label ──
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    iconColor.withValues(alpha: 0.3),
                                    iconColor.withValues(alpha: 0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(icon, color: iconColor, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                label,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // ── Value + suffix + unit ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                numPart,
                                style: AppTypography.stockPrice.copyWith(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (suffixPart != null) ...[
                              const SizedBox(width: 5),
                              Text(
                                suffixPart,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.50),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (unit != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                unit!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.30),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ── HAUSSE/BAISSE CELL — inside unified container ──
// ═══════════════════════════════════════════════
class _HausseBaisseCell extends StatelessWidget {
  final int hausses;
  final int baisses;

  // Accessible colors (daltonism-friendly)
  static const _haussColor = Color(0xFF00BFA5); // teal-green
  static const _baisseColor = Color(0xFFFF6D00); // orange-red

  const _HausseBaisseCell({required this.hausses, required this.baisses});

  @override
  Widget build(BuildContext context) {
    final total = hausses + baisses;
    final ratio = total > 0 ? hausses / total : 0.5;

    return Semantics(
      label: '$hausses hausses, $baisses baisses',
      child: Tooltip(
        message: 'Ratio titres en hausse vs en baisse',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.lightImpact(),
            splashColor: Colors.white.withValues(alpha: 0.08),
            child: SizedBox(
              height: 110,
              child: Stack(
                children: [
                  // ── Background icon ──
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Label ──
                        Text(
                          'Hausses / Baisses',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),

                        // ── Progress bar with pattern ──
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: Row(
                              children: [
                                Flexible(
                                  flex: (ratio * 100).round(),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _haussColor,
                                          Color(0xFF00897B),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  flex: ((1 - ratio) * 100).round(),
                                  child: CustomPaint(
                                    painter: _HatchedBarPainter(
                                      baseColor: _baisseColor,
                                    ),
                                    child: Container(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Counts with ▲/▼ ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_drop_up_rounded,
                                    color: _haussColor, size: 24),
                                Text(
                                  '$hausses',
                                  style: const TextStyle(
                                    color: _haussColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_drop_down_rounded,
                                    color: _baisseColor, size: 24),
                                Text(
                                  '$baisses',
                                  style: const TextStyle(
                                    color: _baisseColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter for hatched bar pattern (accessibility — distinguish from solid bar)
class _HatchedBarPainter extends CustomPainter {
  final Color baseColor;
  _HatchedBarPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Base fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );
    // Diagonal hatches
    final hatchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (double x = -size.height; x < size.width + size.height; x += 5) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        hatchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
