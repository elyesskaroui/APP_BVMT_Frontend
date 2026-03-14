import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/indices_stock_entity.dart';
import '../bloc/indices_bloc.dart';
import '../bloc/indices_event.dart';
import '../bloc/indices_state.dart';

/// Page Indices — Tableau complet des actions BVMT
/// Design premium mobile : cartes compactes, recherche, tri, stats
class IndicesPage extends StatefulWidget {
  const IndicesPage({super.key});

  @override
  State<IndicesPage> createState() => _IndicesPageState();
}

class _IndicesPageState extends State<IndicesPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndicesBloc, IndicesState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildForState(context, state),
        );
      },
    );
  }

  Widget _buildForState(BuildContext context, IndicesState state) {
    if (state is IndicesLoading || state is IndicesInitial) {
      return _buildLoading(key: const ValueKey('loading'));
    }
    if (state is IndicesLoaded) {
      return _buildLoaded(context, state, key: const ValueKey('loaded'));
    }
    if (state is IndicesError) {
      return _buildError(context, state.message, key: const ValueKey('error'));
    }
    return const SizedBox.shrink();
  }

  // ═══════════════════════════════════════════
  // ── LOADING STATE ──
  // ═══════════════════════════════════════════
  Widget _buildLoading({Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(null),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimens.paddingMD),
          itemCount: 12,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusMD),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── LOADED STATE ──
  // ═══════════════════════════════════════════
  Widget _buildLoaded(BuildContext context, IndicesLoaded state, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(state),
      body: FadeTransition(
        opacity: _fadeIn,
        child: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async {
            context.read<IndicesBloc>().add(const IndicesRefreshRequested());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Stats banner ──
              SliverToBoxAdapter(child: _buildStatsBanner(state)),

              // ── Search bar ──
              if (_isSearchOpen)
                SliverToBoxAdapter(child: _buildSearchBar(context)),

              // ── Sort chips ──
              SliverToBoxAdapter(child: _buildSortChips(context, state)),

              // ── Note "en différé" ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMD,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '*En différé de 15 minutes',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stock list ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingMD,
                  4,
                  AppDimens.paddingMD,
                  120,
                ),
                sliver: state.displayedStocks.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmpty())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stock = state.displayedStocks[index];
                            return _IndicesStockCard(
                              stock: stock,
                              index: index,
                            );
                          },
                          childCount: state.displayedStocks.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── APP BAR ──
  // ═══════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(IndicesLoaded? state) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Indices',
                style: AppTypography.onPrimaryTitle.copyWith(
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          if (state != null)
            Text(
              '${state.displayedStocks.length} valeurs',
              style: AppTypography.onPrimaryMuted.copyWith(fontSize: 11),
            ),
        ],
      ),
      actions: [
        // Search toggle
        IconButton(
          icon: Icon(
            _isSearchOpen ? Icons.search_off_rounded : Icons.search_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isSearchOpen = !_isSearchOpen;
              if (!_isSearchOpen) {
                _searchController.clear();
                context.read<IndicesBloc>().add(const IndicesSearchChanged(''));
              } else {
                Future.delayed(const Duration(milliseconds: 200), () {
                  _searchFocusNode.requestFocus();
                });
              }
            });
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── STATS BANNER ──
  // ═══════════════════════════════════════════
  Widget _buildStatsBanner(IndicesLoaded state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.paddingMD,
        AppDimens.paddingMD,
        AppDimens.paddingMD,
        8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A4A), Color(0xFF0F1E36)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
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
        children: [
          // Titre
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
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
              Text(
                'Résumé de la séance',
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatBadge(
                icon: Icons.trending_up_rounded,
                color: AppColors.bullGreen,
                value: '${state.totalHausses}',
                label: 'Hausses',
              ),
              const SizedBox(width: 8),
              _StatBadge(
                icon: Icons.trending_down_rounded,
                color: AppColors.bearRed,
                value: '${state.totalBaisses}',
                label: 'Baisses',
              ),
              const SizedBox(width: 8),
              _StatBadge(
                icon: Icons.remove_rounded,
                color: AppColors.textSecondary,
                value: '${state.totalInchangees}',
                label: 'Inch.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(
                label: 'Transactions',
                value: _formatCompact(state.totalTransactions),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _MiniStat(
                label: 'Volume',
                value: _formatCompact(state.totalVolume),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _MiniStat(
                label: 'Capitaux',
                value: '${_formatCompact(state.totalCapitaux)} TND',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SEARCH BAR ──
  // ═══════════════════════════════════════════
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMD,
        8,
        AppDimens.paddingMD,
        4,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (query) {
          context.read<IndicesBloc>().add(IndicesSearchChanged(query));
        },
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher une valeur...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<IndicesBloc>().add(const IndicesSearchChanged(''));
                  },
                )
              : null,
          fillColor: AppColors.cardBackground,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SORT CHIPS ──
  // ═══════════════════════════════════════════
  Widget _buildSortChips(BuildContext context, IndicesLoaded state) {
    final sortOptions = [
      _SortOption(IndicesSortColumn.name, 'Nom', Icons.sort_by_alpha_rounded),
      _SortOption(IndicesSortColumn.changePercent, 'Variation', Icons.trending_up_rounded),
      _SortOption(IndicesSortColumn.capitaux, 'Capitaux', Icons.account_balance_wallet_rounded),
      _SortOption(IndicesSortColumn.volume, 'Volume', Icons.bar_chart_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMD,
          vertical: 4,
        ),
        itemCount: sortOptions.length,
        itemBuilder: (_, index) {
          final opt = sortOptions[index];
          final isActive = state.sortColumn == opt.column;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<IndicesBloc>().add(IndicesSortRequested(opt.column));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primaryBlue : AppColors.divider,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        opt.icon,
                        size: 14,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        opt.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive ? Colors.white : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 4),
                        Icon(
                          state.sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── EMPTY STATE ──
  // ═══════════════════════════════════════════
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingXL),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue08,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune valeur trouvée',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre terme de recherche',
            style: AppTypography.labelMedium,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── ERROR STATE ──
  // ═══════════════════════════════════════════
  Widget _buildError(BuildContext context, String message, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(null),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<IndicesBloc>().add(const IndicesLoadRequested());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCompact(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

// ═══════════════════════════════════════════════
// ── STOCK CARD — Premium mobile-optimized ──
// ═══════════════════════════════════════════════
class _IndicesStockCard extends StatefulWidget {
  final IndicesStockEntity stock;
  final int index;

  const _IndicesStockCard({required this.stock, required this.index});

  @override
  State<_IndicesStockCard> createState() => _IndicesStockCardState();
}

class _IndicesStockCardState extends State<_IndicesStockCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final changeColor = stock.isPositive
        ? AppColors.bullGreen
        : stock.isNegative
            ? AppColors.bearRed
            : AppColors.textSecondary;
    final changeBg = stock.isPositive
        ? AppColors.bullGreen10
        : stock.isNegative
            ? AppColors.bearRed10
            : AppColors.black04;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpand,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : AppColors.divider.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: _isExpanded
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: _isExpanded ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Main row (always visible) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      // Name + Close
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.name,
                              style: AppTypography.titleSmall.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  stock.formattedClosePrice,
                                  style: AppTypography.stockPrice.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'TND',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Variation badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: changeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!stock.isNeutral)
                              Icon(
                                stock.isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: changeColor,
                              ),
                            if (!stock.isNeutral) const SizedBox(width: 4),
                            Text(
                              stock.formattedChange,
                              style: AppTypography.changePercent.copyWith(
                                color: changeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand arrow
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Expandable details ──
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: AppColors.divider.withValues(alpha: 0.3),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          children: [
                            // Row 1: Ouverture + Clôture
                            Row(
                              children: [
                                Expanded(
                                  child: _DetailItem(
                                    icon: Icons.login_rounded,
                                    label: 'Ouverture',
                                    value: stock.formattedOpenPrice,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DetailItem(
                                    icon: Icons.logout_rounded,
                                    label: 'Clôture',
                                    value: stock.formattedClosePrice,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Row 2: Transactions + Volume
                            Row(
                              children: [
                                Expanded(
                                  child: _DetailItem(
                                    icon: Icons.swap_horiz_rounded,
                                    label: 'Transactions',
                                    value: stock.formattedTransactions,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DetailItem(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Volume',
                                    value: stock.formattedVolume,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Row 3: Capitaux
                            _DetailItem(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Capitaux',
                              value: '${stock.formattedCapitaux} TND',
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ── DETAIL ITEM (inside expanded card) ──
// ═══════════════════════════════════════════════
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue08,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMediumBold.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ── STAT BADGE (in banner) ──
// ═══════════════════════════════════════════════
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.stockPrice.copyWith(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ── MINI STAT (bottom of banner) ──
// ═══════════════════════════════════════════════
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMediumBold.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// ── SORT OPTION MODEL ──
// ═══════════════════════════════════════════════
class _SortOption {
  final IndicesSortColumn column;
  final String label;
  final IconData icon;

  const _SortOption(this.column, this.label, this.icon);
}
