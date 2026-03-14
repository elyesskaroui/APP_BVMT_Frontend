import 'package:equatable/equatable.dart';
import '../../domain/entities/indices_stock_entity.dart';
import '../../domain/entities/index_summary_entity.dart';
import 'indices_event.dart';

/// États BLoC — Indices
abstract class IndicesState extends Equatable {
  const IndicesState();
  @override
  List<Object?> get props => [];
}

class IndicesInitial extends IndicesState {
  const IndicesInitial();
}

class IndicesLoading extends IndicesState {
  const IndicesLoading();
}

class IndicesLoaded extends IndicesState {
  final List<IndicesStockEntity> allStocks;
  final List<IndicesStockEntity> displayedStocks;
  final String searchQuery;
  final IndicesSortColumn sortColumn;
  final bool sortAscending;

  // Statistiques calculées
  final int totalHausses;
  final int totalBaisses;
  final int totalInchangees;
  final int totalTransactions;
  final int totalVolume;
  final int totalCapitaux;

  // Index sélectionné
  final String selectedIndex;
  final List<String> availableIndices;
  final IndexSummaryEntity? indexSummary;
  final List<IndexChartPoint> chartPoints;
  final String chartPeriod;

  const IndicesLoaded({
    required this.allStocks,
    required this.displayedStocks,
    this.searchQuery = '',
    this.sortColumn = IndicesSortColumn.name,
    this.sortAscending = true,
    this.totalHausses = 0,
    this.totalBaisses = 0,
    this.totalInchangees = 0,
    this.totalTransactions = 0,
    this.totalVolume = 0,
    this.totalCapitaux = 0,
    this.selectedIndex = 'TUNINDEX',
    this.availableIndices = const [
      'TUNINDEX',
      'TUNINDEX20',
      'INDICE AGRO ALIMENTAIRE ET BOISSONS',
      'INDICE DE BATIMENT ET MATERIAUX DE CONSTRUCTION',
      'INDICE DE DISTRIBUTION',
      'INDICE DES ASSURANCES',
      'INDICE DES BANQUES',
      'INDICE DES BIENS DE CONSOMMATION',
      'INDICE DES INDUSTRIES',
      'INDICE DES MATERIAUX DE BASE',
      'INDICE DES PRODUITS MENAGERS ET DE SOIN PERSONNEL',
      'INDICE DES SERVICES AUX CONSOMMATEURS',
      'INDICE DES SERVICES FINANCIERS',
      'INDICE DES STE FINANCIERES',
    ],
    this.indexSummary,
    this.chartPoints = const [],
    this.chartPeriod = 'ALL',
  });

  IndicesLoaded copyWith({
    List<IndicesStockEntity>? allStocks,
    List<IndicesStockEntity>? displayedStocks,
    String? searchQuery,
    IndicesSortColumn? sortColumn,
    bool? sortAscending,
    int? totalHausses,
    int? totalBaisses,
    int? totalInchangees,
    int? totalTransactions,
    int? totalVolume,
    int? totalCapitaux,
    String? selectedIndex,
    List<String>? availableIndices,
    IndexSummaryEntity? indexSummary,
    List<IndexChartPoint>? chartPoints,
    String? chartPeriod,
  }) {
    return IndicesLoaded(
      allStocks: allStocks ?? this.allStocks,
      displayedStocks: displayedStocks ?? this.displayedStocks,
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      totalHausses: totalHausses ?? this.totalHausses,
      totalBaisses: totalBaisses ?? this.totalBaisses,
      totalInchangees: totalInchangees ?? this.totalInchangees,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalVolume: totalVolume ?? this.totalVolume,
      totalCapitaux: totalCapitaux ?? this.totalCapitaux,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      availableIndices: availableIndices ?? this.availableIndices,
      indexSummary: indexSummary ?? this.indexSummary,
      chartPoints: chartPoints ?? this.chartPoints,
      chartPeriod: chartPeriod ?? this.chartPeriod,
    );
  }

  @override
  List<Object?> get props => [
        allStocks,
        displayedStocks,
        searchQuery,
        sortColumn,
        sortAscending,
        selectedIndex,
        chartPeriod,
        indexSummary,
      ];
}

class IndicesError extends IndicesState {
  final String message;
  const IndicesError(this.message);
  @override
  List<Object?> get props => [message];
}
