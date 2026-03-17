import '../entities/historique_entity.dart';
import '../repositories/historique_repository.dart';

/// Use Cases — Historique (Clean Architecture)

class GetHistoriqueSessions {
  final HistoriqueRepository repository;
  GetHistoriqueSessions(this.repository);
  Future<List<HistoriqueSessionEntity>> call() => repository.getSessions();
}

class GetHistoriqueChartData {
  final HistoriqueRepository repository;
  GetHistoriqueChartData(this.repository);
  Future<List<HistoriqueChartPoint>> call() => repository.getChartData();
}

class GetSectorBreakdown {
  final HistoriqueRepository repository;
  GetSectorBreakdown(this.repository);
  Future<List<SectorBreakdown>> call() => repository.getSectorBreakdown();
}
