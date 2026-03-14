import '../../../../core/services/market_time_service.dart';
import '../../domain/entities/market_summary_entity.dart';

/// Source de données mock — Résumé du marché (8 slides de la page d'accueil)
/// Données basées sur la séance du 10/03/2026 de la BVMT
class MarketSummaryMockDataSource {
  /// Résumé global
  Future<MarketSummaryEntity> getMarketSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final isOpen = MarketTimeService.isMarketOpen(now);
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return MarketSummaryEntity(
      sessionDate: 'Séance du $dateStr $timeStr',
      isSessionOpen: isOpen,
      isBlocMarketOpen: isOpen,
      tunindex: const IndexData(
        name: 'TUNINDEX',
        value: 15255.00,
        changePercent: 1.16,
        yearChangePercent: 11.89,
        intradayData: [], // rempli par getIndexIntraday
      ),
      tunindex20: const IndexData(
        name: 'TUNINDEX20',
        value: 6684.80,
        changePercent: 1.28,
        yearChangePercent: 11.87,
        intradayData: [],
      ),
      marketCap: 39060297000,
      totalCapitaux: 12914028,
      totalQuantity: 1104673,
      totalTransactions: 2418,
      nbHausses: 28,
      nbBaisses: 22,
      activeValues: 63,
      totalValues: 75,
    );
  }

  /// Données intraday TUNINDEX
  Future<List<ChartPoint>> getTunindexIntraday() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulation de courbe intraday 09:00 → 13:00 (240 min)
    return const [
      ChartPoint(time: 0, value: 15255),
      ChartPoint(time: 10, value: 15260),
      ChartPoint(time: 20, value: 15275),
      ChartPoint(time: 30, value: 15290),
      ChartPoint(time: 40, value: 15280),
      ChartPoint(time: 50, value: 15310),
      ChartPoint(time: 60, value: 15330),
      ChartPoint(time: 70, value: 15315),
      ChartPoint(time: 80, value: 15345),
      ChartPoint(time: 90, value: 15365),
      ChartPoint(time: 100, value: 15350),
      ChartPoint(time: 110, value: 15380),
      ChartPoint(time: 120, value: 15395),
      ChartPoint(time: 130, value: 15375),
      ChartPoint(time: 140, value: 15405),
      ChartPoint(time: 150, value: 15420),
      ChartPoint(time: 160, value: 15440),
      ChartPoint(time: 170, value: 15430),
      ChartPoint(time: 180, value: 15455),
      ChartPoint(time: 190, value: 15465),
      ChartPoint(time: 200, value: 15475),
      ChartPoint(time: 210, value: 15485),
      ChartPoint(time: 220, value: 15478),
      ChartPoint(time: 230, value: 15490),
      ChartPoint(time: 240, value: 15500),
    ];
  }

  /// Données intraday TUNINDEX20
  Future<List<ChartPoint>> getTunindex20Intraday() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      ChartPoint(time: 0, value: 6600),
      ChartPoint(time: 10, value: 6595),
      ChartPoint(time: 20, value: 6610),
      ChartPoint(time: 30, value: 6625),
      ChartPoint(time: 40, value: 6618),
      ChartPoint(time: 50, value: 6635),
      ChartPoint(time: 60, value: 6642),
      ChartPoint(time: 70, value: 6638),
      ChartPoint(time: 80, value: 6648),
      ChartPoint(time: 90, value: 6655),
      ChartPoint(time: 100, value: 6650),
      ChartPoint(time: 110, value: 6658),
      ChartPoint(time: 120, value: 6662),
      ChartPoint(time: 130, value: 6660),
      ChartPoint(time: 140, value: 6668),
      ChartPoint(time: 150, value: 6665),
      ChartPoint(time: 160, value: 6672),
      ChartPoint(time: 170, value: 6670),
      ChartPoint(time: 180, value: 6675),
      ChartPoint(time: 190, value: 6678),
      ChartPoint(time: 200, value: 6680),
      ChartPoint(time: 210, value: 6682),
      ChartPoint(time: 220, value: 6681),
      ChartPoint(time: 230, value: 6683),
      ChartPoint(time: 240, value: 6684.80),
    ];
  }

  /// Top 5 par capitaux échangés
  Future<List<TopStockEntry>> getTopCapitaux() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      TopStockEntry(symbol: 'PGH', lastPrice: 23.700, changePercent: 3.49, metricValue: 3517879),
      TopStockEntry(symbol: 'AB', lastPrice: 58.400, changePercent: 1.74, metricValue: 2285347),
      TopStockEntry(symbol: 'BT', lastPrice: 7.200, changePercent: 1.41, metricValue: 1072666),
      TopStockEntry(symbol: 'SFBT', lastPrice: 13.000, changePercent: 0.00, metricValue: 969154),
      TopStockEntry(symbol: 'BNA', lastPrice: 14.430, changePercent: 1.76, metricValue: 669609),
    ];
  }

  /// Top 5 par quantité traitée
  Future<List<TopStockEntry>> getTopQuantite() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      TopStockEntry(symbol: 'PGH', lastPrice: 23.700, changePercent: 3.49, metricValue: 150065),
      TopStockEntry(symbol: 'BT', lastPrice: 7.200, changePercent: 1.41, metricValue: 149295),
      TopStockEntry(symbol: 'CC', lastPrice: 1.950, changePercent: 3.18, metricValue: 120524),
      TopStockEntry(symbol: 'TGH', lastPrice: 0.830, changePercent: 0.00, metricValue: 80054),
      TopStockEntry(symbol: 'SFBT', lastPrice: 13.000, changePercent: 0.00, metricValue: 74533),
    ];
  }

  /// Top 5 par nombre de transactions
  Future<List<TopStockEntry>> getTopTransactions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      TopStockEntry(symbol: 'PGH', lastPrice: 23.700, changePercent: 3.49, metricValue: 244),
      TopStockEntry(symbol: 'TPR', lastPrice: 13.500, changePercent: -0.15, metricValue: 163),
      TopStockEntry(symbol: 'BNA', lastPrice: 14.430, changePercent: 1.76, metricValue: 163),
      TopStockEntry(symbol: 'AB', lastPrice: 58.400, changePercent: 1.74, metricValue: 159),
      TopStockEntry(symbol: 'SOTUV', lastPrice: 16.000, changePercent: 2.24, metricValue: 144),
    ];
  }

  /// Top 5 plus fortes hausses
  Future<List<TopStockEntry>> getTopHausses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      TopStockEntry(symbol: 'SAH', lastPrice: 13.930, changePercent: 3.96, metricValue: 434723),
      TopStockEntry(symbol: 'PGH', lastPrice: 23.700, changePercent: 3.49, metricValue: 3517879),
      TopStockEntry(symbol: 'CC', lastPrice: 1.950, changePercent: 3.18, metricValue: 233144),
      TopStockEntry(symbol: 'AMV', lastPrice: 8.200, changePercent: 3.15, metricValue: 18566),
      TopStockEntry(symbol: 'ARTES', lastPrice: 14.700, changePercent: 2.80, metricValue: 87684),
    ];
  }

  /// Top 5 plus fortes baisses
  Future<List<TopStockEntry>> getTopBaisses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      TopStockEntry(symbol: 'UADH', lastPrice: 0.450, changePercent: -4.26, metricValue: 3005),
      TopStockEntry(symbol: 'SCB', lastPrice: 0.470, changePercent: -4.08, metricValue: 705),
      TopStockEntry(symbol: 'MNP', lastPrice: 6.400, changePercent: -3.76, metricValue: 14534),
      TopStockEntry(symbol: 'ECYCL', lastPrice: 11.750, changePercent: -2.00, metricValue: 50847),
      TopStockEntry(symbol: 'STB', lastPrice: 4.200, changePercent: -1.87, metricValue: 53548),
    ];
  }
}
