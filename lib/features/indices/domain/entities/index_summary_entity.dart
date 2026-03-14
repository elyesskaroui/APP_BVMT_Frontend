import 'package:equatable/equatable.dart';

/// Entité résumé d'un indice boursier (TUNINDEX, TUNINDEX20, etc.)
/// Correspond à la section résumé sur le site BVMT
class IndexSummaryEntity extends Equatable {
  final String name;
  final double value;         // Valeur actuelle
  final double previousClose; // Veille
  final double changePercent; // Variation %
  final double high;          // Plus haut
  final double low;           // Plus bas
  final double yearChangePercent; // Variation 31/12

  const IndexSummaryEntity({
    required this.name,
    required this.value,
    required this.previousClose,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.yearChangePercent,
  });

  bool get isPositive => changePercent >= 0;
  bool get isNegative => changePercent < 0;

  String get formattedValue => _formatDouble(value);
  String get formattedPreviousClose => _formatDouble(previousClose);
  String get formattedHigh => _formatDouble(high);
  String get formattedLow => _formatDouble(low);

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedYearChange =>
      '${yearChangePercent >= 0 ? '+' : ''}${yearChangePercent.toStringAsFixed(2)}%';

  static String _formatDouble(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart,${parts[1]}';
  }

  @override
  List<Object?> get props => [name, value, changePercent];
}

/// Point de données intraday pour le graphique d'un indice
class IndexChartPoint extends Equatable {
  final double minutesSince9; // minutes depuis 09:00
  final double value;

  const IndexChartPoint({
    required this.minutesSince9,
    required this.value,
  });

  @override
  List<Object?> get props => [minutesSince9, value];
}
