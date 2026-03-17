import 'package:equatable/equatable.dart';
import '../../domain/entities/historique_entity.dart';

/// États BLoC — Historique V3
abstract class HistoriqueState extends Equatable {
  const HistoriqueState();
  @override
  List<Object?> get props => [];
}

/// État initial (pas encore chargé)
class HistoriqueInitial extends HistoriqueState {
  const HistoriqueInitial();
}

/// Chargement en cours
class HistoriqueLoading extends HistoriqueState {
  const HistoriqueLoading();
}

/// Données chargées — V3 complet
class HistoriqueLoaded extends HistoriqueState {
  final List<HistoriqueSessionEntity> sessions;
  final List<HistoriqueChartPoint> chartData;
  final List<SectorBreakdown> sectorBreakdowns;
  final String selectedPeriod;
  final DateTime? selectedDate;
  final bool showTunindex20;

  const HistoriqueLoaded({
    required this.sessions,
    required this.chartData,
    this.sectorBreakdowns = const [],
    this.selectedPeriod = '1A',
    this.selectedDate,
    this.showTunindex20 = true,
  });

  HistoriqueLoaded copyWith({
    List<HistoriqueSessionEntity>? sessions,
    List<HistoriqueChartPoint>? chartData,
    List<SectorBreakdown>? sectorBreakdowns,
    String? selectedPeriod,
    DateTime? selectedDate,
    bool? showTunindex20,
  }) {
    return HistoriqueLoaded(
      sessions: sessions ?? this.sessions,
      chartData: chartData ?? this.chartData,
      sectorBreakdowns: sectorBreakdowns ?? this.sectorBreakdowns,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedDate: selectedDate ?? this.selectedDate,
      showTunindex20: showTunindex20 ?? this.showTunindex20,
    );
  }

  /// Séance sélectionnée (la plus récente si aucune date choisie)
  HistoriqueSessionEntity? get selectedSession {
    if (sessions.isEmpty) return null;
    if (selectedDate == null) return sessions.first;
    try {
      return sessions.firstWhere(
        (s) =>
            s.date.year == selectedDate!.year &&
            s.date.month == selectedDate!.month &&
            s.date.day == selectedDate!.day,
      );
    } catch (_) {
      return sessions.first;
    }
  }

  /// Filtre les points du chart selon la période sélectionnée
  List<HistoriqueChartPoint> get filteredChartData {
    if (chartData.isEmpty) return [];
    final now = chartData.last.date;
    final cutoff = switch (selectedPeriod) {
      '1M' => now.subtract(const Duration(days: 30)),
      '3M' => now.subtract(const Duration(days: 90)),
      '6M' => now.subtract(const Duration(days: 180)),
      '1A' => now.subtract(const Duration(days: 365)),
      '2A' => now.subtract(const Duration(days: 730)),
      _ => chartData.first.date,
    };
    return chartData.where((p) => !p.date.isBefore(cutoff)).toList();
  }

  @override
  List<Object?> get props => [
        sessions,
        chartData,
        sectorBreakdowns,
        selectedPeriod,
        selectedDate,
        showTunindex20,
      ];
}

/// Erreur
class HistoriqueError extends HistoriqueState {
  final String message;
  const HistoriqueError(this.message);

  @override
  List<Object?> get props => [message];
}
