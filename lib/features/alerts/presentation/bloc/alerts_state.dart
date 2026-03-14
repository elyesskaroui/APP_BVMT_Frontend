import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

/// États BLoC — Alertes
abstract class AlertsState extends Equatable {
  const AlertsState();
  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

class AlertsLoaded extends AlertsState {
  final List<AlertEntity> alerts;

  const AlertsLoaded({required this.alerts});

  @override
  List<Object?> get props => [alerts];
}

class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}
