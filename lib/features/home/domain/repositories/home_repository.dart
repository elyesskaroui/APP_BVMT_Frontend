import '../entities/stock_entity.dart';
import '../entities/portfolio_entity.dart';

/// Contrat du repository — couche domain (Clean Architecture)
/// Définit les opérations sans dépendre de l'implémentation
abstract class HomeRepository {
  Future<PortfolioEntity> getPortfolioSummary();
  Future<List<StockEntity>> getFavoriteStocks();
  Future<List<StockEntity>> getTopMovers();
  Future<List<StockEntity>> getTickerData();
  Future<Map<String, dynamic>> getMarketIndices();
  Future<bool> isMarketOpen();
}
