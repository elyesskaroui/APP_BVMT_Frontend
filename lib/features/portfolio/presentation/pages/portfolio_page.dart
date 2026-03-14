import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import '../bloc/portfolio_state.dart';
import '../widgets/portfolio_header_card.dart';
import '../widgets/portfolio_positions_list.dart';
import '../widgets/portfolio_transactions_list.dart';

/// Page Portefeuille — Résumé + Positions + Transactions
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return _buildLoading();
        }
        if (state is PortfolioLoaded) {
          return _buildLoaded(context, state);
        }
        if (state is PortfolioError) {
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

  Widget _buildLoaded(BuildContext context, PortfolioLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          context.read<PortfolioBloc>().add(const PortfolioRefreshRequested());
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
                'Portefeuille',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),

            // ── Carte résumé ──
            SliverToBoxAdapter(
              child: PortfolioHeaderCard(summary: state.summary),
            ),

            // ── Onglets (Positions / Transactions) ──
            SliverToBoxAdapter(
              child: _buildTabs(context, state.currentTab),
            ),

            // ── Contenu selon onglet ──
            SliverToBoxAdapter(
              child: state.currentTab == 0
                  ? PortfolioPositionsList(positions: state.positions)
                  : PortfolioTransactionsList(transactions: state.transactions),
            ),

            // Espace bottom
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, int currentTab) {
    final tabs = ['Positions', 'Transactions'];
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingMD),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == currentTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<PortfolioBloc>().add(PortfolioTabChanged(index));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.cardBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
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
              Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: AppDimens.paddingLG),
              ElevatedButton(
                onPressed: () {
                  context.read<PortfolioBloc>().add(const PortfolioLoadRequested());
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
