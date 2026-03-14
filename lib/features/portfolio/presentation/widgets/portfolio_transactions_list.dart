import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/transaction_entity.dart';

/// Widget — Liste des transactions historiques
class PortfolioTransactionsList extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const PortfolioTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.paddingXL),
        child: Center(
          child: Text(
            'Aucune transaction',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
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
        itemCount: transactions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.divider.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          return _TransactionTile(transaction: transactions[index]);
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.isBuy;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: AppDimens.paddingSM + 4,
      ),
      child: Row(
        children: [
          // ── Icône Achat/Vente ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isBuy ? AppColors.bullGreen : AppColors.bearRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusSM),
            ),
            alignment: Alignment.center,
            child: Icon(
              isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isBuy ? AppColors.bullGreen : AppColors.bearRed,
              size: 20,
            ),
          ),

          const SizedBox(width: AppDimens.paddingSM + 4),

          // ── Symbole + Type + Date ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: (isBuy ? AppColors.bullGreen : AppColors.bearRed)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isBuy ? 'ACHAT' : 'VENTE',
                        style: TextStyle(
                          color: isBuy ? AppColors.bullGreen : AppColors.bearRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.quantity} x ${transaction.price.toStringAsFixed(2)} • ${transaction.formattedDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Montant total ──
          Text(
            '${isBuy ? '-' : '+'}${transaction.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isBuy ? AppColors.bearRed : AppColors.bullGreen,
            ),
          ),
        ],
      ),
    );
  }
}
