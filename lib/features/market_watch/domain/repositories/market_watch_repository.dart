import '../../../home/domain/entities/market_summary_entity.dart';

/// Contrat du repository — Market Watch (Clean Architecture)
abstract class MarketWatchRepository {
  Future<MarketSummaryEntity> getMarketSummary();
  Future<List<ChartPoint>> getTunindexIntraday();
  Future<List<ChartPoint>> getTunindex20Intraday();
  Future<List<TopStockEntry>> getTopHausses();
  Future<List<TopStockEntry>> getTopBaisses();
  Future<List<TopStockEntry>> getTopCapitaux();
  Future<List<TopStockEntry>> getTopQuantite();
  Future<List<TopStockEntry>> getTopTransactions();
}
