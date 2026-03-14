import 'package:equatable/equatable.dart';

/// Entité métier — Données d'un indice boursier
class IndexEntity extends Equatable {
  final String name;
  final double value;
  final double changePercent;
  final double changeValue;
  final List<double> historicalData;

  const IndexEntity({
    required this.name,
    required this.value,
    required this.changePercent,
    this.changeValue = 0,
    this.historicalData = const [],
  });

  bool get isPositive => changePercent >= 0;

  String get formattedValue => value.toStringAsFixed(2);
  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  @override
  List<Object?> get props => [name, value, changePercent];
}
