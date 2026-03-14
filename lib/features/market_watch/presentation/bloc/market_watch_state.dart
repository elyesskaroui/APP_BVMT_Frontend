import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/market_summary_entity.dart';

/// États du BLoC Market Watch
abstract class MarketWatchState extends Equatable {
  const MarketWatchState();

  @override
  List<Object?> get props => [];
}

class MarketWatchInitial extends MarketWatchState {
  const MarketWatchInitial();
}

class MarketWatchLoading extends MarketWatchState {
  const MarketWatchLoading();
}

class MarketWatchLoaded extends MarketWatchState {
  final MarketSummaryEntity summary;
  final List<ChartPoint> tunindexIntraday;
  final List<ChartPoint> tunindex20Intraday;
  final List<TopStockEntry> topHausses;
  final List<TopStockEntry> topBaisses;
  final List<TopStockEntry> topCapitaux;
  final List<TopStockEntry> topQuantite;
  final List<TopStockEntry> topTransactions;
  final int mainTabIndex;
  final int subTabIndex;
  final String chartPeriod;
  final String searchQuery;
  final DateTime lastUpdatedAt;

  MarketWatchLoaded({
    required this.summary,
    required this.tunindexIntraday,
    required this.tunindex20Intraday,
    required this.topHausses,
    required this.topBaisses,
    required this.topCapitaux,
    required this.topQuantite,
    required this.topTransactions,
    this.mainTabIndex = 0,
    this.subTabIndex = 0,
    this.chartPeriod = '1J',
    this.searchQuery = '',
    DateTime? lastUpdatedAt,
  }) : lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  MarketWatchLoaded copyWith({
    MarketSummaryEntity? summary,
    List<ChartPoint>? tunindexIntraday,
    List<ChartPoint>? tunindex20Intraday,
    List<TopStockEntry>? topHausses,
    List<TopStockEntry>? topBaisses,
    List<TopStockEntry>? topCapitaux,
    List<TopStockEntry>? topQuantite,
    List<TopStockEntry>? topTransactions,
    int? mainTabIndex,
    int? subTabIndex,
    String? chartPeriod,
    String? searchQuery,
    DateTime? lastUpdatedAt,
  }) {
    return MarketWatchLoaded(
      summary: summary ?? this.summary,
      tunindexIntraday: tunindexIntraday ?? this.tunindexIntraday,
      tunindex20Intraday: tunindex20Intraday ?? this.tunindex20Intraday,
      topHausses: topHausses ?? this.topHausses,
      topBaisses: topBaisses ?? this.topBaisses,
      topCapitaux: topCapitaux ?? this.topCapitaux,
      topQuantite: topQuantite ?? this.topQuantite,
      topTransactions: topTransactions ?? this.topTransactions,
      mainTabIndex: mainTabIndex ?? this.mainTabIndex,
      subTabIndex: subTabIndex ?? this.subTabIndex,
      chartPeriod: chartPeriod ?? this.chartPeriod,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        tunindexIntraday,
        tunindex20Intraday,
        topHausses,
        topBaisses,
        topCapitaux,
        topQuantite,
        topTransactions,
        mainTabIndex,
        subTabIndex,
        chartPeriod,
        searchQuery,
        lastUpdatedAt,
      ];
}

class MarketWatchError extends MarketWatchState {
  final String message;
  const MarketWatchError(this.message);

  @override
  List<Object?> get props => [message];
}
