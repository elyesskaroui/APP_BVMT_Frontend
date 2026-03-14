import 'package:equatable/equatable.dart';

/// Entité métier — Données d'une action boursière
class StockEntity extends Equatable {
  final String symbol;
  final String companyName;
  final double lastPrice;
  final double changePercent;
  final double changeValue;
  final int volume;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;

  const StockEntity({
    required this.symbol,
    required this.companyName,
    required this.lastPrice,
    required this.changePercent,
    this.changeValue = 0,
    this.volume = 0,
    this.openPrice = 0,
    this.highPrice = 0,
    this.lowPrice = 0,
    this.closePrice = 0,
  });

  bool get isPositive => changePercent >= 0;

  String get formattedPrice => lastPrice.toStringAsFixed(2);
  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  @override
  List<Object?> get props => [symbol, lastPrice, changePercent];
}
