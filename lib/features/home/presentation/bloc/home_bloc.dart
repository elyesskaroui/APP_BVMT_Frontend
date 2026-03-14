import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/home_usecases.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC principal du Dashboard — gère la logique métier de l'accueil
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPortfolioSummary getPortfolioSummary;
  final GetFavoriteStocks getFavoriteStocks;
  final GetTopMovers getTopMovers;
  final GetTickerData getTickerData;
  final CheckMarketStatus checkMarketStatus;

  HomeBloc({
    required this.getPortfolioSummary,
    required this.getFavoriteStocks,
    required this.getTopMovers,
    required this.getTickerData,
    required this.checkMarketStatus,
  }) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        getPortfolioSummary(),
        getFavoriteStocks(),
        getTopMovers(),
        getTickerData(),
        checkMarketStatus(),
      ]);

      // Charger les indices séparément (retourne un Map)
      final indices = await Future.value({'tunindex': {'value': 9245.67, 'change': 0.34}, 'tunindex20': {'value': 4112.33, 'change': -0.12}});

      emit(HomeLoaded(
        portfolio: results[0] as dynamic,
        favoriteStocks: results[1] as dynamic,
        topMovers: results[2] as dynamic,
        tickerData: results[3] as dynamic,
        isMarketOpen: results[4] as bool,
        indices: indices,
        userName: 'Karoui',
      ));
    } catch (e) {
      emit(HomeError('Impossible de charger les données: ${e.toString()}'));
    }
  }
}
