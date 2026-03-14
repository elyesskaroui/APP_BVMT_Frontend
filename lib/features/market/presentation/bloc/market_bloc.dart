import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/stock_entity.dart';
import '../../domain/usecases/market_usecases.dart';
import 'market_event.dart';
import 'market_state.dart';

/// BLoC Market — gère la logique métier de l'écran Marché
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetAllStocks getAllStocks;
  final GetMarketIndices getMarketIndices;
  final SearchStocks searchStocks;
  final GetTopGainers getTopGainers;
  final GetTopLosers getTopLosers;
  final GetMostActive getMostActive;

  MarketBloc({
    required this.getAllStocks,
    required this.getMarketIndices,
    required this.searchStocks,
    required this.getTopGainers,
    required this.getTopLosers,
    required this.getMostActive,
  }) : super(const MarketInitial()) {
    on<MarketLoadRequested>(_onLoadRequested);
    on<MarketRefreshRequested>(_onRefreshRequested);
    on<MarketSearchRequested>(_onSearchRequested);
    on<MarketTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    MarketLoadRequested event,
    Emitter<MarketState> emit,
  ) async {
    emit(const MarketLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    MarketRefreshRequested event,
    Emitter<MarketState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onSearchRequested(
    MarketSearchRequested event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final current = state as MarketLoaded;
      if (event.query.isEmpty) {
        emit(current.copyWith(
          displayedStocks: _getStocksForTab(current, current.currentTab),
          searchQuery: '',
        ));
      } else {
        final results = await searchStocks(event.query);
        emit(current.copyWith(
          displayedStocks: results,
          searchQuery: event.query,
        ));
      }
    }
  }

  Future<void> _onTabChanged(
    MarketTabChanged event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final current = state as MarketLoaded;
      emit(current.copyWith(
        currentTab: event.tabIndex,
        displayedStocks: _getStocksForTab(current, event.tabIndex),
        searchQuery: '',
      ));
    }
  }

  List<StockEntity> _getStocksForTab(MarketLoaded state, int tab) {
    switch (tab) {
      case 1:
        return state.topGainers;
      case 2:
        return state.topLosers;
      case 3:
        return state.mostActive;
      default:
        return state.allStocks;
    }
  }

  Future<void> _loadData(Emitter<MarketState> emit) async {
    try {
      final results = await Future.wait([
        getAllStocks(),
        getMarketIndices(),
        getTopGainers(),
        getTopLosers(),
        getMostActive(),
      ]);

      final allStocks = results[0] as dynamic;
      emit(MarketLoaded(
        allStocks: allStocks,
        displayedStocks: allStocks,
        indices: results[1] as dynamic,
        topGainers: results[2] as dynamic,
        topLosers: results[3] as dynamic,
        mostActive: results[4] as dynamic,
      ));
    } catch (e) {
      emit(MarketError('Impossible de charger les données marché: ${e.toString()}'));
    }
  }
}
