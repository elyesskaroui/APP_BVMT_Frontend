import 'package:equatable/equatable.dart';

/// Événements BLoC — Home
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial de toutes les données du dashboard
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Rafraîchissement (pull-to-refresh)
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Actualisation du ticker temps réel
class HomeTickerUpdateReceived extends HomeEvent {
  const HomeTickerUpdateReceived();
}
