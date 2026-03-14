import 'package:equatable/equatable.dart';

import '../../domain/entities/market_summary_entity.dart';

/// États BLoC — Courbe intraday d'un indice
abstract class IndexChartState extends Equatable {
  const IndexChartState();
  @override
  List<Object?> get props => [];
}

/// État initial (aucun indice sélectionné)
class IndexChartInitial extends IndexChartState {
  const IndexChartInitial();
}

/// Chargement en cours
class IndexChartLoading extends IndexChartState {
  final IndexData index;
  const IndexChartLoading(this.index);

  @override
  List<Object?> get props => [index];
}

/// Données chargées avec succès
class IndexChartLoaded extends IndexChartState {
  final IndexData index;
  final List<ChartPoint> chartData;

  const IndexChartLoaded({
    required this.index,
    required this.chartData,
  });

  @override
  List<Object?> get props => [index, chartData];
}

/// Erreur de chargement
class IndexChartError extends IndexChartState {
  final String message;
  final IndexData index;

  const IndexChartError({
    required this.message,
    required this.index,
  });

  @override
  List<Object?> get props => [message, index];
}
