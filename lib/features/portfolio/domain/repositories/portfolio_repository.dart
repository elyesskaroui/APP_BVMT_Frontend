import '../../../home/domain/entities/portfolio_entity.dart';
import '../entities/position_entity.dart';
import '../entities/transaction_entity.dart';

/// Contrat du repository — couche domain Portfolio
abstract class PortfolioRepository {
  Future<PortfolioEntity> getPortfolioSummary();
  Future<List<PositionEntity>> getPositions();
  Future<List<TransactionEntity>> getTransactions();
}
