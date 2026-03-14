import '../../../home/domain/entities/market_summary_entity.dart';
import '../../domain/repositories/market_watch_repository.dart';
import '../datasources/market_watch_mock_datasource.dart';

/// Implémentation concrète du repository — Market Watch
class MarketWatchRepositoryImpl implements MarketWatchRepository {
  final MarketWatchMockDataSource _dataSource;

  MarketWatchRepositoryImpl({required MarketWatchMockDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<MarketSummaryEntity> getMarketSummary() => _dataSource.getMarketSummary();

  @override
  Future<List<ChartPoint>> getTunindexIntraday() => _dataSource.getTunindexIntraday();

  @override
  Future<List<ChartPoint>> getTunindex20Intraday() => _dataSource.getTunindex20Intraday();

  @override
  Future<List<TopStockEntry>> getTopHausses() => _dataSource.getTopHausses();

  @override
  Future<List<TopStockEntry>> getTopBaisses() => _dataSource.getTopBaisses();

  @override
  Future<List<TopStockEntry>> getTopCapitaux() => _dataSource.getTopCapitaux();

  @override
  Future<List<TopStockEntry>> getTopQuantite() => _dataSource.getTopQuantite();

  @override
  Future<List<TopStockEntry>> getTopTransactions() => _dataSource.getTopTransactions();
}
