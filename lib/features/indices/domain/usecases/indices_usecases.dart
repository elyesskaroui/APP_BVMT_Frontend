import '../entities/indices_stock_entity.dart';
import '../repositories/indices_repository.dart';

/// Use Cases — couche domain Indices (Clean Architecture)
/// Chaque use case = une action métier unique

class GetAllIndicesStocks {
  final IndicesRepository repository;
  GetAllIndicesStocks(this.repository);

  Future<List<IndicesStockEntity>> call() => repository.getAllIndicesStocks();
}

class SearchIndicesStocks {
  final IndicesRepository repository;
  SearchIndicesStocks(this.repository);

  Future<List<IndicesStockEntity>> call(String query) =>
      repository.searchStocks(query);
}
