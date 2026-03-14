import 'package:equatable/equatable.dart';

/// Entité métier — Donnée d'une action dans le tableau des indices BVMT
/// Correspond au tableau affiché sur le site web BVMT
class IndicesStockEntity extends Equatable {
  final String name;
  final double? openPrice;
  final double closePrice;
  final double changePercent;
  final int? transactions;
  final int? volume;
  final int? capitaux;

  const IndicesStockEntity({
    required this.name,
    this.openPrice,
    required this.closePrice,
    required this.changePercent,
    this.transactions,
    this.volume,
    this.capitaux,
  });

  bool get isPositive => changePercent > 0;
  bool get isNegative => changePercent < 0;
  bool get isNeutral => changePercent == 0;

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedClosePrice => _formatPrice(closePrice);
  String get formattedOpenPrice =>
      openPrice != null ? _formatPrice(openPrice!) : '-';

  String get formattedTransactions =>
      transactions != null ? _formatInt(transactions!) : '-';
  String get formattedVolume =>
      volume != null ? _formatIntSpaced(volume!) : '-';
  String get formattedCapitaux =>
      capitaux != null ? _formatIntSpaced(capitaux!) : '-';

  static String _formatPrice(double v) => v.toStringAsFixed(3);

  static String _formatInt(int v) => v.toString();

  static String _formatIntSpaced(int v) {
    return v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }

  @override
  List<Object?> get props => [name, closePrice, changePercent];
}
