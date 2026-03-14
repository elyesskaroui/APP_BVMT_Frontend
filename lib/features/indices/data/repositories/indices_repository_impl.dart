import '../../domain/entities/indices_stock_entity.dart';
import '../../domain/repositories/indices_repository.dart';
import '../datasources/indices_mock_datasource.dart';

/// Implémentation concrète du repository Indices
/// Fait le pont entre la couche domain et la couche data
class IndicesRepositoryImpl implements IndicesRepository {
  final IndicesMockDataSource _dataSource;

  IndicesRepositoryImpl({required IndicesMockDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<IndicesStockEntity>> getAllIndicesStocks() =>
      _dataSource.getAllIndicesStocks();

  @override
  Future<List<IndicesStockEntity>> searchStocks(String query) =>
      _dataSource.searchStocks(query);
}
