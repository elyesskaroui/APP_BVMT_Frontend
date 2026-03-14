import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/portfolio_entity.dart';

/// États BLoC — Home
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

/// État initial (aucun chargement)
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Chargement en cours
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Données chargées avec succès
class HomeLoaded extends HomeState {
  final PortfolioEntity portfolio;
  final List<StockEntity> favoriteStocks;
  final List<StockEntity> topMovers;
  final List<StockEntity> tickerData;
  final Map<String, dynamic> indices;
  final bool isMarketOpen;
  final String userName;

  const HomeLoaded({
    required this.portfolio,
    required this.favoriteStocks,
    required this.topMovers,
    required this.tickerData,
    required this.indices,
    required this.isMarketOpen,
    this.userName = 'Mariam',
  });

  @override
  List<Object?> get props => [
        portfolio,
        favoriteStocks,
        topMovers,
        tickerData,
        indices,
        isMarketOpen,
      ];
}

/// Erreur de chargement
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
