import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/stock_entity.dart';

/// Widget composé — Section "Top Movers" (plus fortes variations)
class HomeTopMovers extends StatelessWidget {
  final List<StockEntity> movers;

  const HomeTopMovers({super.key, required this.movers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Top Movers',
          actionText: 'Voir tout',
        ),
        SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
            itemCount: movers.length,
            itemBuilder: (context, index) {
              final stock = movers[index];
              return _MoverCard(stock: stock);
            },
          ),
        ),
      ],
    );
  }
}

class _MoverCard extends StatelessWidget {
  final StockEntity stock;
  const _MoverCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stock/${stock.symbol}'),
      child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppDimens.paddingSM),
      padding: const EdgeInsets.all(AppDimens.paddingSM + 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  stock.symbol.substring(0, stock.symbol.length >= 2 ? 2 : stock.symbol.length),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  stock.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            stock.formattedPrice,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (stock.isPositive ? AppColors.bullGreen : AppColors.bearRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stock.isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: stock.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                  size: 18,
                ),
                Text(
                  stock.formattedChange,
                  style: TextStyle(
                    color: stock.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
