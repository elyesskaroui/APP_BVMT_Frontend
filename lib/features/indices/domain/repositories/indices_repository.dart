import '../entities/indices_stock_entity.dart';

/// Contrat du repository — couche domain (Clean Architecture)
/// Définit l'interface que la couche data doit implémenter
abstract class IndicesRepository {
  Future<List<IndicesStockEntity>> getAllIndicesStocks();
  Future<List<IndicesStockEntity>> searchStocks(String query);
}
