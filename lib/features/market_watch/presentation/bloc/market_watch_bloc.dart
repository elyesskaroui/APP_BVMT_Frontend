import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/market_watch_usecases.dart';
import 'market_watch_event.dart';
import 'market_watch_state.dart';

/// BLoC Market Watch — gère la logique métier de la page Market Watch
class MarketWatchBloc extends Bloc<MarketWatchEvent, MarketWatchState> {
  final GetMarketWatchSummary getMarketWatchSummary;
  final GetMWTunindexIntraday getMWTunindexIntraday;
  final GetMWTunindex20Intraday getMWTunindex20Intraday;
  final GetMWTopHausses getMWTopHausses;
  final GetMWTopBaisses getMWTopBaisses;
  final GetMWTopCapitaux getMWTopCapitaux;
  final GetMWTopQuantite getMWTopQuantite;
  final GetMWTopTransactions getMWTopTransactions;

  Timer? _autoRefreshTimer;

  MarketWatchBloc({
    required this.getMarketWatchSummary,
    required this.getMWTunindexIntraday,
    required this.getMWTunindex20Intraday,
    required this.getMWTopHausses,
    required this.getMWTopBaisses,
    required this.getMWTopCapitaux,
    required this.getMWTopQuantite,
    required this.getMWTopTransactions,
  }) : super(const MarketWatchInitial()) {
    on<MarketWatchLoadRequested>(_onLoadRequested);
    on<MarketWatchRefreshRequested>(_onRefreshRequested);
    on<MarketWatchMainTabChanged>(_onMainTabChanged);
    on<MarketWatchSubTabChanged>(_onSubTabChanged);
    on<MarketWatchChartPeriodChanged>(_onChartPeriodChanged);
    on<MarketWatchSearchChanged>(_onSearchChanged);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const MarketWatchRefreshRequested()),
    );
  }

  Future<void> _onLoadRequested(
    MarketWatchLoadRequested event,
    Emitter<MarketWatchState> emit,
  ) async {
    emit(const MarketWatchLoading());
    await _loadData(emit);
    _startAutoRefresh();
  }

  Future<void> _onRefreshRequested(
    MarketWatchRefreshRequested event,
    Emitter<MarketWatchState> emit,
  ) async {
    await _loadData(emit, preserveTabs: true);
  }

  Future<void> _onMainTabChanged(
    MarketWatchMainTabChanged event,
    Emitter<MarketWatchState> emit,
  ) async {
    if (state is MarketWatchLoaded) {
      emit((state as MarketWatchLoaded).copyWith(mainTabIndex: event.tabIndex));
    }
  }

  Future<void> _onSubTabChanged(
    MarketWatchSubTabChanged event,
    Emitter<MarketWatchState> emit,
  ) async {
    if (state is MarketWatchLoaded) {
      emit((state as MarketWatchLoaded).copyWith(subTabIndex: event.subTabIndex));
    }
  }

  Future<void> _onChartPeriodChanged(
    MarketWatchChartPeriodChanged event,
    Emitter<MarketWatchState> emit,
  ) async {
    if (state is MarketWatchLoaded) {
      emit((state as MarketWatchLoaded).copyWith(chartPeriod: event.period));
    }
  }

  Future<void> _onSearchChanged(
    MarketWatchSearchChanged event,
    Emitter<MarketWatchState> emit,
  ) async {
    if (state is MarketWatchLoaded) {
      emit((state as MarketWatchLoaded).copyWith(searchQuery: event.query));
    }
  }

  Future<void> _loadData(
    Emitter<MarketWatchState> emit, {
    bool preserveTabs = false,
  }) async {
    try {
      final results = await Future.wait([
        getMarketWatchSummary(),       // 0
        getMWTunindexIntraday(),       // 1
        getMWTunindex20Intraday(),     // 2
        getMWTopHausses(),             // 3
        getMWTopBaisses(),             // 4
        getMWTopCapitaux(),            // 5
        getMWTopQuantite(),            // 6
        getMWTopTransactions(),        // 7
      ]);

      final currentState = state;
      emit(MarketWatchLoaded(
        summary: results[0] as dynamic,
        tunindexIntraday: results[1] as dynamic,
        tunindex20Intraday: results[2] as dynamic,
        topHausses: results[3] as dynamic,
        topBaisses: results[4] as dynamic,
        topCapitaux: results[5] as dynamic,
        topQuantite: results[6] as dynamic,
        topTransactions: results[7] as dynamic,
        mainTabIndex: preserveTabs && currentState is MarketWatchLoaded
            ? currentState.mainTabIndex
            : 0,
        subTabIndex: preserveTabs && currentState is MarketWatchLoaded
            ? currentState.subTabIndex
            : 0,
        chartPeriod: preserveTabs && currentState is MarketWatchLoaded
            ? currentState.chartPeriod
            : '1J',
        searchQuery: preserveTabs && currentState is MarketWatchLoaded
            ? currentState.searchQuery
            : '',
        lastUpdatedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(MarketWatchError('Impossible de charger les données: $e'));
    }
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
