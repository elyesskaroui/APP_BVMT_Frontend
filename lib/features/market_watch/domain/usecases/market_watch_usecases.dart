import '../../../home/domain/entities/market_summary_entity.dart';
import '../repositories/market_watch_repository.dart';

/// Use Cases — Market Watch (Clean Architecture)
/// Chaque use case = une action métier unique

class GetMarketWatchSummary {
  final MarketWatchRepository repository;
  GetMarketWatchSummary(this.repository);
  Future<MarketSummaryEntity> call() => repository.getMarketSummary();
}

class GetMWTunindexIntraday {
  final MarketWatchRepository repository;
  GetMWTunindexIntraday(this.repository);
  Future<List<ChartPoint>> call() => repository.getTunindexIntraday();
}

class GetMWTunindex20Intraday {
  final MarketWatchRepository repository;
  GetMWTunindex20Intraday(this.repository);
  Future<List<ChartPoint>> call() => repository.getTunindex20Intraday();
}

class GetMWTopHausses {
  final MarketWatchRepository repository;
  GetMWTopHausses(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopHausses();
}

class GetMWTopBaisses {
  final MarketWatchRepository repository;
  GetMWTopBaisses(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopBaisses();
}

class GetMWTopCapitaux {
  final MarketWatchRepository repository;
  GetMWTopCapitaux(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopCapitaux();
}

class GetMWTopQuantite {
  final MarketWatchRepository repository;
  GetMWTopQuantite(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopQuantite();
}

class GetMWTopTransactions {
  final MarketWatchRepository repository;
  GetMWTopTransactions(this.repository);
  Future<List<TopStockEntry>> call() => repository.getTopTransactions();
}
