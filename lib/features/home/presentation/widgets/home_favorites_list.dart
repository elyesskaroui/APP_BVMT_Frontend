import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/stock_entity.dart';

/// Widget composé — Section "Favoris" avec liste d'actions favorites
class HomeFavoritesList extends StatelessWidget {
  final List<StockEntity> stocks;

  const HomeFavoritesList({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SectionHeader(
          title: 'Favoris',
          actionText: 'Voir tout',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stocks.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.5),
              indent: AppDimens.paddingMD + 40 + AppDimens.paddingSM + 4,
            ),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return StockListItem(
                symbol: stock.symbol,
                companyName: stock.companyName,
                price: stock.formattedPrice,
                changePercent: stock.formattedChange,
                isPositive: stock.isPositive,
                onTap: () => context.push('/stock/${stock.symbol}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
