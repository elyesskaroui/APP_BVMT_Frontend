import '../entities/historique_entity.dart';

/// Contrat du repository — Historique (Clean Architecture)
abstract class HistoriqueRepository {
  /// Retourne les séances historiques (les plus récentes en premier)
  Future<List<HistoriqueSessionEntity>> getSessions();

  /// Retourne les points pour la courbe dual-axis TUNINDEX / TUNINDEX20
  Future<List<HistoriqueChartPoint>> getChartData();

  /// Retourne la répartition sectorielle
  Future<List<SectorBreakdown>> getSectorBreakdown();
}
