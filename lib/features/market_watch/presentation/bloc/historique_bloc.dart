import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/historique_usecases.dart';
import 'historique_event.dart';
import 'historique_state.dart';

/// BLoC Historique V3 — gère le chargement des données historiques
/// Pattern : lazy-load (chargé uniquement quand on switch sur l'onglet Historique)
class HistoriqueBloc extends Bloc<HistoriqueEvent, HistoriqueState> {
  final GetHistoriqueSessions getHistoriqueSessions;
  final GetHistoriqueChartData getHistoriqueChartData;
  final GetSectorBreakdown getSectorBreakdown;

  HistoriqueBloc({
    required this.getHistoriqueSessions,
    required this.getHistoriqueChartData,
    required this.getSectorBreakdown,
  }) : super(const HistoriqueInitial()) {
    on<HistoriqueLoadRequested>(_onLoadRequested);
    on<HistoriquePeriodChanged>(_onPeriodChanged);
    on<HistoriqueDateChanged>(_onDateChanged);
    on<HistoriqueToggleTunindex20>(_onToggleTunindex20);
  }

  Future<void> _onLoadRequested(
    HistoriqueLoadRequested event,
    Emitter<HistoriqueState> emit,
  ) async {
    emit(const HistoriqueLoading());
    try {
      final results = await Future.wait([
        getHistoriqueSessions(),
        getHistoriqueChartData(),
        getSectorBreakdown(),
      ]);
      emit(HistoriqueLoaded(
        sessions: results[0] as dynamic,
        chartData: results[1] as dynamic,
        sectorBreakdowns: results[2] as dynamic,
      ));
    } catch (e) {
      emit(HistoriqueError('Erreur lors du chargement: $e'));
    }
  }

  void _onPeriodChanged(
    HistoriquePeriodChanged event,
    Emitter<HistoriqueState> emit,
  ) {
    if (state is HistoriqueLoaded) {
      emit((state as HistoriqueLoaded).copyWith(
        selectedPeriod: event.period,
      ));
    }
  }

  void _onDateChanged(
    HistoriqueDateChanged event,
    Emitter<HistoriqueState> emit,
  ) {
    if (state is HistoriqueLoaded) {
      emit((state as HistoriqueLoaded).copyWith(
        selectedDate: event.date,
      ));
    }
  }

  void _onToggleTunindex20(
    HistoriqueToggleTunindex20 event,
    Emitter<HistoriqueState> emit,
  ) {
    if (state is HistoriqueLoaded) {
      final loaded = state as HistoriqueLoaded;
      emit(loaded.copyWith(
        showTunindex20: !loaded.showTunindex20,
      ));
    }
  }
}
