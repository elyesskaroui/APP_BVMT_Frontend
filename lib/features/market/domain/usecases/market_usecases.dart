import '../../../home/domain/entities/stock_entity.dart';
import '../entities/index_entity.dart';
import '../repositories/market_repository.dart';

/// Use Cases — couche domain Market

class GetAllStocks {
  final MarketRepository repository;
  GetAllStocks(this.repository);

  Future<List<StockEntity>> call() => repository.getAllStocks();
}

class SearchStocks {
  final MarketRepository repository;
  SearchStocks(this.repository);

  Future<List<StockEntity>> call(String query) =>
      repository.getStocksBySearch(query);
}

class GetMarketIndices {
  final MarketRepository repository;
  GetMarketIndices(this.repository);

  Future<List<IndexEntity>> call() => repository.getMarketIndices();
}

class GetTopGainers {
  final MarketRepository repository;
  GetTopGainers(this.repository);

  Future<List<StockEntity>> call() => repository.getTopGainers();
}

class GetTopLosers {
  final MarketRepository repository;
  GetTopLosers(this.repository);

  Future<List<StockEntity>> call() => repository.getTopLosers();
}

class GetMostActive {
  final MarketRepository repository;
  GetMostActive(this.repository);

  Future<List<StockEntity>> call() => repository.getMostActive();
}
