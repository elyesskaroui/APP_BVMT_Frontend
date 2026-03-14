import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/alert_entity.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

/// BLoC Alertes — gère les alertes de prix
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  AlertsBloc() : super(const AlertsInitial()) {
    on<AlertsLoadRequested>(_onLoadRequested);
    on<AlertToggled>(_onToggled);
    on<AlertDeleted>(_onDeleted);
    on<AlertCreated>(_onCreated);
  }

  Future<void> _onLoadRequested(
    AlertsLoadRequested event,
    Emitter<AlertsState> emit,
  ) async {
    emit(const AlertsLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    // Données mock
    final alerts = [
      AlertEntity(
        id: 'ALR001',
        symbol: 'BIAT',
        companyName: 'Banque Internationale Arabe de Tunisie',
        targetPrice: 110.00,
        condition: 'above',
        isActive: true,
        createdAt: DateTime(2026, 2, 28),
      ),
      AlertEntity(
        id: 'ALR002',
        symbol: 'SFBT',
        companyName: 'Société Frigorifique et Brasserie de Tunis',
        targetPrice: 20.00,
        condition: 'below',
        isActive: true,
        createdAt: DateTime(2026, 2, 25),
      ),
      AlertEntity(
        id: 'ALR003',
        symbol: 'PGH',
        companyName: 'Poulina Group Holding',
        targetPrice: 13.50,
        condition: 'above',
        isActive: false,
        createdAt: DateTime(2026, 2, 20),
      ),
      AlertEntity(
        id: 'ALR004',
        symbol: 'STAR',
        companyName: "Société Tunisienne d'Assurances",
        targetPrice: 140.00,
        condition: 'below',
        isActive: true,
        createdAt: DateTime(2026, 2, 15),
      ),
    ];

    emit(AlertsLoaded(alerts: alerts));
  }

  Future<void> _onToggled(
    AlertToggled event,
    Emitter<AlertsState> emit,
  ) async {
    if (state is AlertsLoaded) {
      final current = state as AlertsLoaded;
      final updatedAlerts = current.alerts.map((a) {
        if (a.id == event.alertId) {
          return AlertEntity(
            id: a.id,
            symbol: a.symbol,
            companyName: a.companyName,
            targetPrice: a.targetPrice,
            condition: a.condition,
            isActive: !a.isActive,
            createdAt: a.createdAt,
          );
        }
        return a;
      }).toList();
      emit(AlertsLoaded(alerts: updatedAlerts));
    }
  }

  Future<void> _onDeleted(
    AlertDeleted event,
    Emitter<AlertsState> emit,
  ) async {
    if (state is AlertsLoaded) {
      final current = state as AlertsLoaded;
      final updatedAlerts = current.alerts.where((a) => a.id != event.alertId).toList();
      emit(AlertsLoaded(alerts: updatedAlerts));
    }
  }

  void _onCreated(
    AlertCreated event,
    Emitter<AlertsState> emit,
  ) {
    final List<AlertEntity> currentAlerts;
    if (state is AlertsLoaded) {
      currentAlerts = List.from((state as AlertsLoaded).alerts);
    } else {
      currentAlerts = [];
    }

    final newAlert = AlertEntity(
      id: 'ALR${DateTime.now().millisecondsSinceEpoch}',
      symbol: event.symbol,
      companyName: event.symbol,
      targetPrice: event.targetPrice,
      condition: event.condition,
      isActive: true,
      createdAt: DateTime.now(),
    );

    currentAlerts.insert(0, newAlert);
    emit(AlertsLoaded(alerts: currentAlerts));
  }
}
