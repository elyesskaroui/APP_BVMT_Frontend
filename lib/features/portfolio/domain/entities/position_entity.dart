import 'package:equatable/equatable.dart';

/// Entité métier — Position dans le portefeuille
class PositionEntity extends Equatable {
  final String symbol;
  final String companyName;
  final int quantity;
  final double avgPrice;
  final double currentPrice;
  final double changePercent;

  const PositionEntity({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    this.changePercent = 0,
  });

  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * avgPrice;
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent => totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0;
  bool get isPositive => gainLoss >= 0;

  String get formattedGainLoss =>
      '${isPositive ? '+' : ''}${gainLoss.toStringAsFixed(2)} TND';
  String get formattedGainLossPercent =>
      '${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [symbol, quantity, avgPrice, currentPrice];
}
