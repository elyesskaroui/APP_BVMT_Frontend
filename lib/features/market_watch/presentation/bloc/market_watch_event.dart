import 'package:equatable/equatable.dart';

/// Événements du BLoC Market Watch
abstract class MarketWatchEvent extends Equatable {
  const MarketWatchEvent();

  @override
  List<Object?> get props => [];
}

/// Chargement initial de toutes les données
class MarketWatchLoadRequested extends MarketWatchEvent {
  const MarketWatchLoadRequested();
}

/// Rafraîchissement (pull-to-refresh)
class MarketWatchRefreshRequested extends MarketWatchEvent {
  const MarketWatchRefreshRequested();
}

/// Changement d'onglet principal (Live / Historique)
class MarketWatchMainTabChanged extends MarketWatchEvent {
  final int tabIndex;
  const MarketWatchMainTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Changement de sous-onglet (Résumé / Tout / Marché / Indices)
class MarketWatchSubTabChanged extends MarketWatchEvent {
  final int subTabIndex;
  const MarketWatchSubTabChanged(this.subTabIndex);

  @override
  List<Object?> get props => [subTabIndex];
}

/// Changement de période du chart (1J / 1S / 1M / 1A)
class MarketWatchChartPeriodChanged extends MarketWatchEvent {
  final String period;
  const MarketWatchChartPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

/// Recherche de valeur
class MarketWatchSearchChanged extends MarketWatchEvent {
  final String query;
  const MarketWatchSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
