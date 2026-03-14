import '../../domain/entities/market_summary_entity.dart';
import '../../domain/repositories/market_summary_repository.dart';
import '../datasources/market_summary_mock_datasource.dart';

/// Implémentation du repository — Résumé du marché
class MarketSummaryRepositoryImpl implements MarketSummaryRepository {
  final MarketSummaryMockDataSource _dataSource;

  MarketSummaryRepositoryImpl({MarketSummaryMockDataSource? dataSource})
      : _dataSource = dataSource ?? MarketSummaryMockDataSource();

  @override
  Future<MarketSummaryEntity> getMarketSummary() =>
      _dataSource.getMarketSummary();

  @override
  Future<List<ChartPoint>> getTunindexIntraday() =>
      _dataSource.getTunindexIntraday();

  @override
  Future<List<ChartPoint>> getTunindex20Intraday() =>
      _dataSource.getTunindex20Intraday();

  @override
  Future<List<TopStockEntry>> getTopCapitaux() =>
      _dataSource.getTopCapitaux();

  @override
  Future<List<TopStockEntry>> getTopQuantite() =>
      _dataSource.getTopQuantite();

  @override
  Future<List<TopStockEntry>> getTopTransactions() =>
      _dataSource.getTopTransactions();

  @override
  Future<List<TopStockEntry>> getTopHausses() =>
      _dataSource.getTopHausses();

  @override
  Future<List<TopStockEntry>> getTopBaisses() =>
      _dataSource.getTopBaisses();
}
