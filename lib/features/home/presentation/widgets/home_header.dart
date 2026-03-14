import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/cubits/market_status_cubit.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/portfolio_entity.dart';

/// Widget composé — Header bleu gradient avec infos portefeuille
/// Reproduit le design de la maquette (gradient bleu + carte portfolio)
class HomeHeader extends StatelessWidget {
  final String userName;
  final PortfolioEntity portfolio;
  final bool isMarketOpen;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.portfolio,
    required this.isMarketOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar (logo + icônes) ──
            _buildTopBar(context),

            const SizedBox(height: AppDimens.paddingSM),

            // ── Carte portefeuille ──
            PortfolioSummaryCard(
              userName: userName,
              portfolioAmount: portfolio.formattedValue,
              currency: portfolio.currency,
              changePercent: portfolio.formattedChange,
              isPositive: portfolio.isPositive,
              sparklineData: portfolio.sparklineData,
            ),

            const SizedBox(height: AppDimens.paddingMD),

            // ── Badge statut marché (mis à jour automatiquement) ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMD,
              ),
              child: BlocBuilder<MarketStatusCubit, MarketStatusState>(
                builder: (context, marketStatus) {
                  return Row(
                    children: [
                      MarketStatusBadge(isOpen: marketStatus.isOpen),
                      const Spacer(),
                      Text(
                        marketStatus.statusText,
                        style: TextStyle(
                          color: AppColors.textOnPrimaryMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimens.paddingMD),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: AppDimens.paddingSM,
      ),
      child: Row(
        children: [
          // Logo BVMT
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusSM),
            ),
            child: const Text(
              'BVMT',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const Spacer(),

          // Bouton recherche
          _buildIconButton(Icons.search_rounded),
          const SizedBox(width: 8),
          // Bouton notifications
          _buildIconButton(Icons.notifications_outlined, hasBadge: true),
          const SizedBox(width: 8),
          // Avatar utilisateur
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accentOrange,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusSM),
          ),
          child: Icon(icon, color: AppColors.textOnPrimary, size: 22),
        ),
        if (hasBadge)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
