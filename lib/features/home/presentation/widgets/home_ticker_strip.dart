import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/stock_entity.dart';

/// Widget composé — Barre de ticker défilant (cours temps réel)
class HomeTickerStrip extends StatelessWidget {
  final List<StockEntity> stocks;

  const HomeTickerStrip({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    return TickerBar(
      items: stocks
          .map((s) => TickerItem(
                symbol: s.symbol,
                price: s.formattedPrice,
                change: s.formattedChange,
                isPositive: s.isPositive,
              ))
          .toList(),
    );
  }
}
