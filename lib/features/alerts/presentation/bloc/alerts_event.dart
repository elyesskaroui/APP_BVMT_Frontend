import 'package:equatable/equatable.dart';

/// Événements BLoC — Alertes
abstract class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object?> get props => [];
}

class AlertsLoadRequested extends AlertsEvent {
  const AlertsLoadRequested();
}

class AlertToggled extends AlertsEvent {
  final String alertId;
  const AlertToggled(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertDeleted extends AlertsEvent {
  final String alertId;
  const AlertDeleted(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertCreated extends AlertsEvent {
  final String symbol;
  final double targetPrice;
  final String condition;

  const AlertCreated({
    required this.symbol,
    required this.targetPrice,
    required this.condition,
  });

  @override
  List<Object?> get props => [symbol, targetPrice, condition];
}
