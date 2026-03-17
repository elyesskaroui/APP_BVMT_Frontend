import 'package:equatable/equatable.dart';

/// Événements BLoC — Historique V3
abstract class HistoriqueEvent extends Equatable {
  const HistoriqueEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial des données historiques
class HistoriqueLoadRequested extends HistoriqueEvent {
  const HistoriqueLoadRequested();
}

/// Changement de la période d'affichage du chart
class HistoriquePeriodChanged extends HistoriqueEvent {
  final String period; // '1M', '3M', '6M', '1A', '2A'
  const HistoriquePeriodChanged(this.period);
  @override
  List<Object?> get props => [period];
}

/// Sélection d'une date dans le Date Picker
class HistoriqueDateChanged extends HistoriqueEvent {
  final DateTime date;
  const HistoriqueDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

/// Toggle de la visibilité TUNINDEX20
class HistoriqueToggleTunindex20 extends HistoriqueEvent {
  const HistoriqueToggleTunindex20();
}
