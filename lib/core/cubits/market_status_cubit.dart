import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/market_time_service.dart';

// ── States ──

/// État du statut marché
class MarketStatusState extends Equatable {
  final bool isOpen;
  final String statusText;

  const MarketStatusState({
    required this.isOpen,
    required this.statusText,
  });

  @override
  List<Object?> get props => [isOpen, statusText];
}

// ── Cubit ──

/// Cubit qui gère le statut ouvert/fermé du marché BVMT
/// Se met à jour automatiquement toutes les 30 secondes
class MarketStatusCubit extends Cubit<MarketStatusState> {
  Timer? _timer;

  MarketStatusCubit()
      : super(MarketStatusState(
          isOpen: MarketTimeService.isMarketOpen(),
          statusText: MarketTimeService.statusText(),
        )) {
    _startTimer();
  }

  /// Démarre le timer de vérification périodique
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkStatus();
    });
  }

  /// Vérifie et met à jour le statut
  void _checkStatus() {
    final isOpen = MarketTimeService.isMarketOpen();
    final text = MarketTimeService.statusText();

    final newState = MarketStatusState(isOpen: isOpen, statusText: text);

    // N'émet que si le statut a changé
    if (newState != state) {
      emit(newState);
    }
  }

  /// Force une mise à jour manuelle
  void refresh() => _checkStatus();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
