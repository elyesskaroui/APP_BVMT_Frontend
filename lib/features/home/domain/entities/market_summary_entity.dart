import 'package:equatable/equatable.dart';

/// Entité — Résumé global du marché (page d'accueil slide "Global")
class MarketSummaryEntity extends Equatable {
  final String sessionDate;
  final bool isSessionOpen;
  final bool isBlocMarketOpen;

  // Indices
  final IndexData tunindex;
  final IndexData tunindex20;

  // Stats globales
  final double marketCap; // Capitalisation boursière
  final double totalCapitaux; // Capitaux échangés
  final int totalQuantity; // Quantité traitée
  final int totalTransactions; // Nombre de transactions
  final int nbHausses;
  final int nbBaisses;
  final int activeValues;
  final int totalValues;

  const MarketSummaryEntity({
    required this.sessionDate,
    required this.isSessionOpen,
    this.isBlocMarketOpen = false,
    required this.tunindex,
    required this.tunindex20,
    required this.marketCap,
    required this.totalCapitaux,
    required this.totalQuantity,
    required this.totalTransactions,
    required this.nbHausses,
    required this.nbBaisses,
    required this.activeValues,
    required this.totalValues,
  });

  @override
  List<Object?> get props => [
        sessionDate,
        isSessionOpen,
        tunindex,
        tunindex20,
        marketCap,
        totalCapitaux,
        totalTransactions,
      ];
}

/// Données d'un indice boursier (TUNINDEX ou TUNINDEX20)
class IndexData extends Equatable {
  final String name;
  final double value;
  final double changePercent;
  final double yearChangePercent;
  final List<ChartPoint> intradayData;

  const IndexData({
    required this.name,
    required this.value,
    required this.changePercent,
    required this.yearChangePercent,
    this.intradayData = const [],
  });

  bool get isPositive => changePercent >= 0;

  String get formattedValue {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart,${parts[1]}';
  }

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedYearChange =>
      '${yearChangePercent >= 0 ? '+' : ''}${yearChangePercent.toStringAsFixed(2)}%';

  @override
  List<Object?> get props => [name, value, changePercent, yearChangePercent];
}

/// Point de données pour courbe intraday
class ChartPoint extends Equatable {
  final double time; // minutes depuis 09:00
  final double value;

  const ChartPoint({required this.time, required this.value});

  @override
  List<Object?> get props => [time, value];
}

/// Entrée d'un classement (Top Capitaux, Quantité, Transactions, Hausses, Baisses)
class TopStockEntry extends Equatable {
  final String symbol;
  final double lastPrice;
  final double changePercent;
  final double metricValue; // Capitaux, Quantité, NbTransactions, etc.

  const TopStockEntry({
    required this.symbol,
    required this.lastPrice,
    required this.changePercent,
    required this.metricValue,
  });

  bool get isPositive => changePercent > 0;
  bool get isNegative => changePercent < 0;
  bool get isNeutral => changePercent == 0;

  String get formattedPrice {
    if (lastPrice < 1) return lastPrice.toStringAsFixed(3);
    if (lastPrice < 100) return lastPrice.toStringAsFixed(3);
    return lastPrice.toStringAsFixed(3);
  }

  String get formattedChange =>
      '${changePercent >= 0 ? '' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedMetric {
    if (metricValue >= 1000000) {
      return '${(metricValue / 1000000).toStringAsFixed(1)} M';
    }
    return metricValue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  @override
  List<Object?> get props => [symbol, lastPrice, changePercent, metricValue];
}
