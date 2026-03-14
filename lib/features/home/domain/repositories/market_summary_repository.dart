import '../entities/market_summary_entity.dart';

/// Contrat du repository — Résumé du marché
abstract class MarketSummaryRepository {
  Future<MarketSummaryEntity> getMarketSummary();
  Future<List<ChartPoint>> getTunindexIntraday();
  Future<List<ChartPoint>> getTunindex20Intraday();
  Future<List<TopStockEntry>> getTopCapitaux();
  Future<List<TopStockEntry>> getTopQuantite();
  Future<List<TopStockEntry>> getTopTransactions();
  Future<List<TopStockEntry>> getTopHausses();
  Future<List<TopStockEntry>> getTopBaisses();
}
