import '../../../home/domain/entities/portfolio_entity.dart';
import '../entities/position_entity.dart';
import '../entities/transaction_entity.dart';
import '../repositories/portfolio_repository.dart';

/// Use Cases — couche domain Portfolio

class GetPortfolioDetail {
  final PortfolioRepository repository;
  GetPortfolioDetail(this.repository);

  Future<PortfolioEntity> call() => repository.getPortfolioSummary();
}

class GetPositions {
  final PortfolioRepository repository;
  GetPositions(this.repository);

  Future<List<PositionEntity>> call() => repository.getPositions();
}

class GetTransactions {
  final PortfolioRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionEntity>> call() => repository.getTransactions();
}
