import 'package:equatable/equatable.dart';

/// Entité métier — Résumé du portefeuille utilisateur
class PortfolioEntity extends Equatable {
  final double totalValue;
  final double changePercent;
  final String currency;
  final List<double> sparklineData;

  const PortfolioEntity({
    required this.totalValue,
    required this.changePercent,
    this.currency = 'TND',
    this.sparklineData = const [],
  });

  bool get isPositive => changePercent >= 0;

  String get formattedValue {
    final parts = totalValue.toStringAsFixed(3).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [totalValue, changePercent];
}
