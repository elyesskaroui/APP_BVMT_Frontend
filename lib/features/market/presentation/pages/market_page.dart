import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/market_indices_header.dart';
import '../widgets/market_stock_table.dart';

/// Page Marché — Vue détaillée de toutes les actions
class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return _buildLoading();
        }
        if (state is MarketLoaded) {
          return _buildLoaded(context, state);
        }
        if (state is MarketError) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, MarketLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          context.read<MarketBloc>().add(const MarketRefreshRequested());
        },
        child: CustomScrollView(
          slivers: [
            // ── App Bar gradient ──
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                ),
              ),
              title: const Text(
                'Marché',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppColors.textOnPrimary),
                  onPressed: () {},
                ),
              ],
            ),

            // ── Indices ──
            SliverToBoxAdapter(
              child: MarketIndicesHeader(indices: state.indices),
            ),

            // ── Barre de recherche ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingMD),
                child: TextField(
                  onChanged: (query) {
                    context.read<MarketBloc>().add(MarketSearchRequested(query));
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une action...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    fillColor: AppColors.cardBackground,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // ── Tabs (Toutes / Hausse / Baisse / Volume) ──
            SliverToBoxAdapter(
              child: _buildTabs(context, state.currentTab),
            ),

            // ── Table Actions ──
            SliverToBoxAdapter(
              child: MarketStockTable(stocks: state.displayedStocks),
            ),

            // Espace bottom
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, int currentTab) {
    final tabs = ['Toutes', 'Hausse', 'Baisse', 'Volume'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isActive = index == currentTab;
          return GestureDetector(
            onTap: () {
              context.read<MarketBloc>().add(MarketTabChanged(index));
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppDimens.paddingSM),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                border: Border.all(
                  color: isActive ? AppColors.primaryBlue : AppColors.divider,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.bearRed, size: 64),
              const SizedBox(height: AppDimens.paddingMD),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: AppDimens.paddingLG),
              ElevatedButton(
                onPressed: () {
                  context.read<MarketBloc>().add(const MarketLoadRequested());
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
