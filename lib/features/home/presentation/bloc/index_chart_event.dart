import 'package:equatable/equatable.dart';

import '../../domain/entities/market_summary_entity.dart';

/// Événements BLoC — Courbe intraday d'un indice
abstract class IndexChartEvent extends Equatable {
  const IndexChartEvent();
  @override
  List<Object?> get props => [];
}

/// Demande de chargement des données intraday pour un indice
class IndexChartRequested extends IndexChartEvent {
  final IndexData index;
  const IndexChartRequested(this.index);

  @override
  List<Object?> get props => [index];
}
