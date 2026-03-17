import '../../domain/entities/historique_entity.dart';
import '../../domain/repositories/historique_repository.dart';
import '../datasources/historique_mock_datasource.dart';

/// Implémentation Mock du repository — Historique
class HistoriqueRepositoryImpl implements HistoriqueRepository {
  final HistoriqueMockDataSource dataSource;

  HistoriqueRepositoryImpl({required this.dataSource});

  @override
  Future<List<HistoriqueSessionEntity>> getSessions() =>
      dataSource.getSessions();

  @override
  Future<List<HistoriqueChartPoint>> getChartData() =>
      dataSource.getChartData();

  @override
  Future<List<SectorBreakdown>> getSectorBreakdown() =>
      dataSource.getSectorBreakdown();
}
