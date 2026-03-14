import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/portfolio_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_mock_datasource.dart';

/// Implémentation concrète du repository — couche data
/// Connecte la couche domain aux sources de données
class HomeRepositoryImpl implements HomeRepository {
  final HomeMockDataSource _dataSource;

  HomeRepositoryImpl({HomeMockDataSource? dataSource})
      : _dataSource = dataSource ?? HomeMockDataSource();

  @override
  Future<PortfolioEntity> getPortfolioSummary() =>
      _dataSource.getPortfolioSummary();

  @override
  Future<List<StockEntity>> getFavoriteStocks() =>
      _dataSource.getFavoriteStocks();

  @override
  Future<List<StockEntity>> getTopMovers() => _dataSource.getTopMovers();

  @override
  Future<List<StockEntity>> getTickerData() => _dataSource.getTickerData();

  @override
  Future<Map<String, dynamic>> getMarketIndices() =>
      _dataSource.getMarketIndices();

  @override
  Future<bool> isMarketOpen() => _dataSource.isMarketOpen();
}
