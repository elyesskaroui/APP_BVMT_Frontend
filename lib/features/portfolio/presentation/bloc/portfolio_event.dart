import 'package:equatable/equatable.dart';

/// Événements BLoC — Portfolio
abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial du portefeuille
class PortfolioLoadRequested extends PortfolioEvent {
  const PortfolioLoadRequested();
}

/// Rafraîchissement
class PortfolioRefreshRequested extends PortfolioEvent {
  const PortfolioRefreshRequested();
}

/// Changement d'onglet (Positions / Transactions)
class PortfolioTabChanged extends PortfolioEvent {
  final int tabIndex;
  const PortfolioTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
