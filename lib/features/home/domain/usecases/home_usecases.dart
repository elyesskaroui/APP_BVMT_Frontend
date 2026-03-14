import '../entities/stock_entity.dart';
import '../entities/portfolio_entity.dart';
import '../repositories/home_repository.dart';

/// Use Cases — couche domain (Clean Architecture)
/// Chaque use case représente une action métier unique

class GetPortfolioSummary {
  final HomeRepository repository;
  GetPortfolioSummary(this.repository);

  Future<PortfolioEntity> call() => repository.getPortfolioSummary();
}

class GetFavoriteStocks {
  final HomeRepository repository;
  GetFavoriteStocks(this.repository);

  Future<List<StockEntity>> call() => repository.getFavoriteStocks();
}

class GetTopMovers {
  final HomeRepository repository;
  GetTopMovers(this.repository);

  Future<List<StockEntity>> call() => repository.getTopMovers();
}

class GetTickerData {
  final HomeRepository repository;
  GetTickerData(this.repository);

  Future<List<StockEntity>> call() => repository.getTickerData();
}

class CheckMarketStatus {
  final HomeRepository repository;
  CheckMarketStatus(this.repository);

  Future<bool> call() => repository.isMarketOpen();
}
