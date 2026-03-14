import '../../../home/domain/entities/stock_entity.dart';
import '../entities/index_entity.dart';

/// Contrat du repository — couche domain (Clean Architecture)
abstract class MarketRepository {
  Future<List<StockEntity>> getAllStocks();
  Future<List<StockEntity>> getStocksBySearch(String query);
  Future<List<IndexEntity>> getMarketIndices();
  Future<StockEntity> getStockDetail(String symbol);
  Future<List<StockEntity>> getTopGainers();
  Future<List<StockEntity>> getTopLosers();
  Future<List<StockEntity>> getMostActive();
}
