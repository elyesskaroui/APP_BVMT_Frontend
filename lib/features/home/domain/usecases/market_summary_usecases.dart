import '../entities/market_summary_entity.dart';
import '../repositories/market_summary_repository.dart';

/// Use Cases — Résumé du marché

class GetMarketSummary {
  final MarketSummaryRepository repository;
  GetMarketSummary(this.repository);
  Future<MarketSummaryEntity> call() => repository.getMarketSummary();
}

class GetTunindexIntraday {
  final MarketSummaryRepository repository;
  GetTunindexIntraday(this.repository);
  Future<List<ChartPoint>> call() => repository.getTunindexIntraday();
}

class GetTunindex20Intraday {
  final MarketSummaryRepository repository;
  GetTunindex20Intraday(this.repository);
  Future<List<ChartPoint>> call() => repository.getTunindex20Intraday();
}

class GetTopCapitaux {
  final MarketSummaryRepository repository;
  GetTopCapitaux(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopCapitaux();
}

class GetTopQuantite {
  final MarketSummaryRepository repository;
  GetTopQuantite(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopQuantite();
}

class GetTopTransactions {
  final MarketSummaryRepository repository;
  GetTopTransactions(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopTransactions();
}

class GetTopHausses {
  final MarketSummaryRepository repository;
  GetTopHausses(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopHausses();
}

class GetTopBaisses {
  final MarketSummaryRepository repository;
  GetTopBaisses(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopBaisses();
}
