import '../../../home/domain/entities/stock_entity.dart';
import '../../domain/entities/index_entity.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_mock_datasource.dart';

/// Implémentation concrète du repository Market
class MarketRepositoryImpl implements MarketRepository {
  final MarketMockDataSource _dataSource;

  MarketRepositoryImpl({MarketMockDataSource? dataSource})
      : _dataSource = dataSource ?? MarketMockDataSource();

  @override
  Future<List<StockEntity>> getAllStocks() => _dataSource.getAllStocks();

  @override
  Future<List<StockEntity>> getStocksBySearch(String query) =>
      _dataSource.getStocksBySearch(query);

  @override
  Future<List<IndexEntity>> getMarketIndices() =>
      _dataSource.getMarketIndices();

  @override
  Future<StockEntity> getStockDetail(String symbol) =>
      _dataSource.getStockDetail(symbol);

  @override
  Future<List<StockEntity>> getTopGainers() => _dataSource.getTopGainers();

  @override
  Future<List<StockEntity>> getTopLosers() => _dataSource.getTopLosers();

  @override
  Future<List<StockEntity>> getMostActive() => _dataSource.getMostActive();
}
