import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/market_summary_entity.dart';
import '../../domain/usecases/market_summary_usecases.dart';
import 'index_chart_event.dart';
import 'index_chart_state.dart';

/// BLoC — Courbe intraday d'un indice (TUNINDEX / TUNINDEX20)
///
/// Gère le cycle complet :
/// 1. Lecture du cache GetStorage (affichage immédiat si disponible)
/// 2. Fetch des données fraîches via Use Case
/// 3. Mise à jour du cache GetStorage
class IndexChartBloc extends Bloc<IndexChartEvent, IndexChartState> {
  final GetTunindexIntraday getTunindexIntraday;
  final GetTunindex20Intraday getTunindex20Intraday;
  final LocalStorageService localStorage;

  IndexChartBloc({
    required this.getTunindexIntraday,
    required this.getTunindex20Intraday,
    required this.localStorage,
  }) : super(const IndexChartInitial()) {
    on<IndexChartRequested>(_onChartRequested);
  }

  Future<void> _onChartRequested(
    IndexChartRequested event,
    Emitter<IndexChartState> emit,
  ) async {
    // ── 1. Vérifier le cache GetStorage ──
    final cached = localStorage.getCachedChartData(event.index.name);
    if (cached != null && cached.isNotEmpty) {
      // Affichage immédiat des données en cache
      emit(IndexChartLoaded(index: event.index, chartData: cached));
    } else {
      // Pas de cache → afficher un loading
      emit(IndexChartLoading(event.index));
    }

    // ── 2. Fetch des données fraîches via Use Case ──
    try {
      final List<ChartPoint> freshData;
      if (event.index.name == 'TUNINDEX') {
        freshData = await getTunindexIntraday();
      } else {
        freshData = await getTunindex20Intraday();
      }

      // ── 3. Sauvegarder en cache GetStorage ──
      localStorage.cacheChartData(event.index.name, freshData);

      // ── 4. Émettre les données fraîches ──
      emit(IndexChartLoaded(index: event.index, chartData: freshData));
    } catch (e) {
      // Ne pas écraser les données en cache en cas d'erreur réseau
      if (state is! IndexChartLoaded) {
        emit(IndexChartError(
          message: 'Impossible de charger les données: ${e.toString()}',
          index: event.index,
        ));
      }
    }
  }
}
