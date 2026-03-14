import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/widgets/widgets.dart';

/// Widget composé — Ligne des indices TUNINDEX / TUNINDEX20
class HomeIndicesRow extends StatelessWidget {
  final Map<String, dynamic> indices;

  const HomeIndicesRow({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    final tunindex = indices['tunindex'] as Map<String, dynamic>?;
    final tunindex20 = indices['tunindex20'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: IndexCard(
              indexName: 'TUNINDEX',
              value: _formatValue(tunindex?['value'] ?? 0),
              changePercent: _formatChange(tunindex?['change'] ?? 0),
              isPositive: (tunindex?['change'] ?? 0) >= 0,
            ),
          ),
          const SizedBox(width: AppDimens.paddingSM),
          Expanded(
            child: IndexCard(
              indexName: 'TUNINDEX20',
              value: _formatValue(tunindex20?['value'] ?? 0),
              changePercent: _formatChange(tunindex20?['change'] ?? 0),
              isPositive: (tunindex20?['change'] ?? 0) >= 0,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(num value) => value.toStringAsFixed(2);

  String _formatChange(num change) =>
      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
}
