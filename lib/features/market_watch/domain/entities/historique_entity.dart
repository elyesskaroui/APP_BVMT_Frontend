import 'package:equatable/equatable.dart';

/// Entité — Données historiques d'une séance boursière
class HistoriqueSessionEntity extends Equatable {
  final DateTime date;
  final double tunindexValue;
  final double tunindexChange;
  final double tunindex20Value;
  final double tunindex20Change;
  final double totalCapitaux;
  final int totalQuantite;
  final int totalTransactions;
  final int nbHausses;
  final int nbBaisses;
  final int nbInchangees;
  final double capBoursiere; // Capitalisation boursière

  const HistoriqueSessionEntity({
    required this.date,
    required this.tunindexValue,
    required this.tunindexChange,
    required this.tunindex20Value,
    required this.tunindex20Change,
    required this.totalCapitaux,
    required this.totalQuantite,
    required this.totalTransactions,
    required this.nbHausses,
    required this.nbBaisses,
    required this.nbInchangees,
    this.capBoursiere = 0,
  });

  String get formattedDate {
    final d = date;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get shortDate {
    const months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return '${date.day} ${months[date.month]}';
  }

  String get formattedCapitaux {
    if (totalCapitaux >= 1e9) {
      return '${(totalCapitaux / 1e9).toStringAsFixed(1)} Mrd';
    }
    if (totalCapitaux >= 1e6) {
      return '${(totalCapitaux / 1e6).toStringAsFixed(1)} M';
    }
    if (totalCapitaux >= 1e3) {
      return '${(totalCapitaux / 1e3).toStringAsFixed(0)} K';
    }
    return totalCapitaux.toStringAsFixed(0);
  }

  @override
  List<Object?> get props => [date, tunindexValue, tunindex20Value];
}

/// Point de données pour la courbe historique dual-axis
class HistoriqueChartPoint extends Equatable {
  final DateTime date;
  final double tunindex;
  final double tunindex20;

  const HistoriqueChartPoint({
    required this.date,
    required this.tunindex,
    required this.tunindex20,
  });

  @override
  List<Object?> get props => [date, tunindex, tunindex20];
}

/// Répartition sectorielle pour le breakdown card
class SectorBreakdown extends Equatable {
  final String name;
  final double percentage;
  final double variation;
  final int nbSocietes;

  const SectorBreakdown({
    required this.name,
    required this.percentage,
    required this.variation,
    required this.nbSocietes,
  });

  @override
  List<Object?> get props => [name, percentage, variation];
}

