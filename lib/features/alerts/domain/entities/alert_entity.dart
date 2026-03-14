import 'package:equatable/equatable.dart';

/// Entité métier — Alerte de prix
class AlertEntity extends Equatable {
  final String id;
  final String symbol;
  final String companyName;
  final double targetPrice;
  final String condition; // 'above' or 'below'
  final bool isActive;
  final DateTime createdAt;

  const AlertEntity({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.targetPrice,
    required this.condition,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAbove => condition == 'above';

  String get conditionText => isAbove ? 'Au-dessus de' : 'En-dessous de';

  String get formattedPrice => '${targetPrice.toStringAsFixed(2)} TND';

  @override
  List<Object?> get props => [id, symbol, targetPrice, condition, isActive];
}
