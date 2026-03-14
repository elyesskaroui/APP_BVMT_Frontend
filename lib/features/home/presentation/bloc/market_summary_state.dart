import 'package:equatable/equatable.dart';

import '../../../news/domain/entities/news_entity.dart';
import '../../domain/entities/market_summary_entity.dart';

/// States pour le BLoC du résumé marché
abstract class MarketSummaryState extends Equatable {
  const MarketSummaryState();
  @override
  List<Object?> get props => [];
}

class MarketSummaryInitial extends MarketSummaryState {
  const MarketSummaryInitial();
}

class MarketSummaryLoading extends MarketSummaryState {
  const MarketSummaryLoading();
}

class MarketSummaryLoaded extends MarketSummaryState {
  final MarketSummaryEntity summary;
  final List<ChartPoint> tunindexIntraday;
  final List<ChartPoint> tunindex20Intraday;
  final List<TopStockEntry> topCapitaux;
  final List<TopStockEntry> topQuantite;
  final List<TopStockEntry> topTransactions;
  final List<TopStockEntry> topHausses;
  final List<TopStockEntry> topBaisses;
  final List<NewsEntity> latestNews;
  final int currentPage;

  const MarketSummaryLoaded({
    required this.summary,
    required this.tunindexIntraday,
    required this.tunindex20Intraday,
    required this.topCapitaux,
    required this.topQuantite,
    required this.topTransactions,
    required this.topHausses,
    required this.topBaisses,
    required this.latestNews,
    this.currentPage = 0,
  });

  MarketSummaryLoaded copyWith({
    MarketSummaryEntity? summary,
    List<ChartPoint>? tunindexIntraday,
    List<ChartPoint>? tunindex20Intraday,
    List<TopStockEntry>? topCapitaux,
    List<TopStockEntry>? topQuantite,
    List<TopStockEntry>? topTransactions,
    List<TopStockEntry>? topHausses,
    List<TopStockEntry>? topBaisses,
    List<NewsEntity>? latestNews,
    int? currentPage,
  }) {
    return MarketSummaryLoaded(
      summary: summary ?? this.summary,
      tunindexIntraday: tunindexIntraday ?? this.tunindexIntraday,
      tunindex20Intraday: tunindex20Intraday ?? this.tunindex20Intraday,
      topCapitaux: topCapitaux ?? this.topCapitaux,
      topQuantite: topQuantite ?? this.topQuantite,
      topTransactions: topTransactions ?? this.topTransactions,
      topHausses: topHausses ?? this.topHausses,
      topBaisses: topBaisses ?? this.topBaisses,
      latestNews: latestNews ?? this.latestNews,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        tunindexIntraday,
        tunindex20Intraday,
        topCapitaux,
        topQuantite,
        topTransactions,
        topHausses,
        topBaisses,
        latestNews,
        currentPage,
      ];
}

class MarketSummaryError extends MarketSummaryState {
  final String message;
  const MarketSummaryError(this.message);
  @override
  List<Object?> get props => [message];
}
