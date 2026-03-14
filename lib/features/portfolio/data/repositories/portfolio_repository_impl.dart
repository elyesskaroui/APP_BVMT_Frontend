import '../../../home/domain/entities/portfolio_entity.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_mock_datasource.dart';

/// Implémentation concrète du repository Portfolio
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioMockDataSource _dataSource;

  PortfolioRepositoryImpl({PortfolioMockDataSource? dataSource})
      : _dataSource = dataSource ?? PortfolioMockDataSource();

  @override
  Future<PortfolioEntity> getPortfolioSummary() =>
      _dataSource.getPortfolioSummary();

  @override
  Future<List<PositionEntity>> getPositions() => _dataSource.getPositions();

  @override
  Future<List<TransactionEntity>> getTransactions() =>
      _dataSource.getTransactions();
}
