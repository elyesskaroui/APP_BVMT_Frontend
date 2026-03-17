import 'dart:math';
import '../../domain/entities/historique_entity.dart';

/// Source de données mock — Historique BVMT
/// Données réalistes calquées sur la courbe réelle nov.2025 → mars 2026
/// Pattern : montée lente → léger creux → rallye fort
class HistoriqueMockDataSource {
  Future<List<HistoriqueSessionEntity>> getSessions() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _generateSessions();
  }

  Future<List<HistoriqueChartPoint>> getChartData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _generateChartPoints();
  }

  Future<List<SectorBreakdown>> getSectorBreakdown() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      SectorBreakdown(name: 'Banques', percentage: 42.3, variation: 1.85, nbSocietes: 12),
      SectorBreakdown(name: 'Assurances', percentage: 11.7, variation: 0.92, nbSocietes: 6),
      SectorBreakdown(name: 'Leasing', percentage: 8.4, variation: -0.35, nbSocietes: 8),
      SectorBreakdown(name: 'Agroalimentaire', percentage: 7.8, variation: 2.15, nbSocietes: 5),
      SectorBreakdown(name: 'Distribution', percentage: 6.2, variation: 0.48, nbSocietes: 7),
      SectorBreakdown(name: 'Immobilier', percentage: 5.1, variation: -1.20, nbSocietes: 4),
      SectorBreakdown(name: 'Industries', percentage: 4.9, variation: 0.67, nbSocietes: 9),
      SectorBreakdown(name: 'Services Financiers', percentage: 4.3, variation: 1.32, nbSocietes: 3),
      SectorBreakdown(name: 'Télécoms', percentage: 3.8, variation: -0.15, nbSocietes: 2),
      SectorBreakdown(name: 'Autres', percentage: 5.5, variation: 0.25, nbSocietes: 18),
    ];
  }

  // ── Génère ~120 séances avec courbe réaliste ──
  List<HistoriqueSessionEntity> _generateSessions() {
    final rng = Random(42);
    final sessions = <HistoriqueSessionEntity>[];

    // Valeurs de départ (mars 2026)
    var tunindex = 15255.0;
    var tunindex20 = 6684.8;
    var date = DateTime(2026, 3, 16);

    for (var i = 0; i < 120; i++) {
      date = _previousBusinessDay(date);

      // Biais selon la phase pour reproduire la courbe réelle
      final phase = i / 120.0;
      double bias;
      if (phase < 0.2) {
        bias = 0.003; // Récent: légère hausse
      } else if (phase < 0.4) {
        bias = 0.005; // Rallye fort
      } else if (phase < 0.6) {
        bias = -0.002; // Creux
      } else {
        bias = 0.002; // Montée lente initiale
      }
      final tunChange = (rng.nextDouble() * 2.0 - 0.8 + bias * 100) / 100;
      final tun20Change = (rng.nextDouble() * 2.2 - 0.9 + bias * 100) / 100;

      tunindex *= (1 - tunChange);
      tunindex20 *= (1 - tun20Change);

      final capitaux = 5e6 + rng.nextDouble() * 25e6;
      final quantite = 500000 + rng.nextInt(1800000);
      final transactions = 1500 + rng.nextInt(2500);
      final hausses = 15 + rng.nextInt(30);
      final baisses = 8 + rng.nextInt(22);
      final inchangees = 5 + rng.nextInt(15);
      final cap = 38e9 + rng.nextDouble() * 3e9;

      sessions.add(HistoriqueSessionEntity(
        date: date,
        tunindexValue: double.parse(tunindex.toStringAsFixed(2)),
        tunindexChange: double.parse((tunChange * 100).toStringAsFixed(2)),
        tunindex20Value: double.parse(tunindex20.toStringAsFixed(2)),
        tunindex20Change: double.parse((tun20Change * 100).toStringAsFixed(2)),
        totalCapitaux: capitaux,
        totalQuantite: quantite,
        totalTransactions: transactions,
        nbHausses: hausses,
        nbBaisses: baisses,
        nbInchangees: inchangees,
        capBoursiere: cap,
      ));
    }

    return sessions;
  }

  // ── Courbe réaliste: slow rise → slight dip → strong rally ──
  List<HistoriqueChartPoint> _generateChartPoints() {
    final points = <HistoriqueChartPoint>[];
    var date = DateTime(2024, 3, 1);

    // Phase segments for realistic BVMT shape
    // Phase 1: Mar-Jun 2024 — Slow rise (13200 → 13800)
    // Phase 2: Jul-Sep 2024 — Slight dip (13800 → 13500)
    // Phase 3: Oct-Nov 2024 — Recovery (13500 → 14200)
    // Phase 4: Dec 2024-Jan 2025 — Plateau (14200 → 14300)
    // Phase 5: Feb-Jun 2025 — Steady climb (14300 → 14900)
    // Phase 6: Jul-Sep 2025 — Small correction (14900 → 14600)
    // Phase 7: Oct 2025-Jan 2026 — Strong rally (14600 → 15100)
    // Phase 8: Feb-Mar 2026 — Final push (15100 → 15255)

    final rng = Random(77);
    var tunindex = 13200.0;
    var tunindex20 = 5780.0;

    for (var i = 0; i < 520; i++) {
      date = _nextBusinessDay(date);
      if (date.isAfter(DateTime(2026, 3, 16))) break;

      final dayOfYear = date.difference(DateTime(2024, 3, 1)).inDays;
      final progress = dayOfYear / 745.0; // ~2 years

      // Trend function
      double trend;
      if (progress < 0.12) {
        trend = 4.0; // Slow rise
      } else if (progress < 0.24) {
        trend = -2.5; // Slight dip
      } else if (progress < 0.35) {
        trend = 5.0; // Recovery
      } else if (progress < 0.45) {
        trend = 1.0; // Plateau
      } else if (progress < 0.60) {
        trend = 3.5; // Steady climb
      } else if (progress < 0.72) {
        trend = -1.5; // Small correction
      } else if (progress < 0.90) {
        trend = 5.5; // Strong rally
      } else {
        trend = 3.0; // Final push
      }

      tunindex += trend + (rng.nextDouble() * 12 - 6);
      tunindex20 += (trend * 0.45) + (rng.nextDouble() * 5.5 - 2.75);
      tunindex = tunindex.clamp(12800.0, 15800.0);
      tunindex20 = tunindex20.clamp(5500.0, 7000.0);

      points.add(HistoriqueChartPoint(
        date: date,
        tunindex: double.parse(tunindex.toStringAsFixed(2)),
        tunindex20: double.parse(tunindex20.toStringAsFixed(2)),
      ));
    }

    return points;
  }

  DateTime _previousBusinessDay(DateTime d) {
    var prev = d.subtract(const Duration(days: 1));
    while (prev.weekday == DateTime.saturday ||
        prev.weekday == DateTime.sunday) {
      prev = prev.subtract(const Duration(days: 1));
    }
    return prev;
  }

  DateTime _nextBusinessDay(DateTime d) {
    var next = d.add(const Duration(days: 1));
    while (next.weekday == DateTime.saturday ||
        next.weekday == DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
}
