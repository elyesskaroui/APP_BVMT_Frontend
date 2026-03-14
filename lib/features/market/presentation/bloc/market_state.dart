import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/stock_entity.dart';
import '../../domain/entities/index_entity.dart';

/// États BLoC — Market
abstract class MarketState extends Equatable {
  const MarketState();
  @override
  List<Object?> get props => [];
}

/// État initial
class MarketInitial extends MarketState {
  const MarketInitial();
}

/// Chargement en cours
class MarketLoading extends MarketState {
  const MarketLoading();
}

/// Données du marché chargées
class MarketLoaded extends MarketState {
  final List<StockEntity> allStocks;
  final List<StockEntity> displayedStocks;
  final List<IndexEntity> indices;
  final List<StockEntity> topGainers;
  final List<StockEntity> topLosers;
  final List<StockEntity> mostActive;
  final int currentTab;
  final String searchQuery;

  const MarketLoaded({
    required this.allStocks,
    required this.displayedStocks,
    required this.indices,
    required this.topGainers,
    required this.topLosers,
    required this.mostActive,
    this.currentTab = 0,
    this.searchQuery = '',
  });

  MarketLoaded copyWith({
    List<StockEntity>? allStocks,
    List<StockEntity>? displayedStocks,
    List<IndexEntity>? indices,
    List<StockEntity>? topGainers,
    List<StockEntity>? topLosers,
    List<StockEntity>? mostActive,
    int? currentTab,
    String? searchQuery,
  }) {
    return MarketLoaded(
      allStocks: allStocks ?? this.allStocks,
      displayedStocks: displayedStocks ?? this.displayedStocks,
      indices: indices ?? this.indices,
      topGainers: topGainers ?? this.topGainers,
      topLosers: topLosers ?? this.topLosers,
      mostActive: mostActive ?? this.mostActive,
      currentTab: currentTab ?? this.currentTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        allStocks,
        displayedStocks,
        indices,
        topGainers,
        topLosers,
        mostActive,
        currentTab,
        searchQuery,
      ];
}

/// Erreur de chargement
class MarketError extends MarketState {
  final String message;
  const MarketError(this.message);

  @override
  List<Object?> get props => [message];
}
