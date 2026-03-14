import '../../../home/domain/entities/stock_entity.dart';
import '../../domain/entities/index_entity.dart';

/// Source de données mock pour le Market
class MarketMockDataSource {
  Future<List<StockEntity>> getAllStocks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      StockEntity(symbol: 'BIAT', companyName: 'Banque Internationale Arabe de Tunisie', lastPrice: 108.50, changePercent: 1.25, volume: 15420),
      StockEntity(symbol: 'SFBT', companyName: 'Société Frigorifique et Brasserie de Tunis', lastPrice: 21.30, changePercent: -0.47, volume: 8900),
      StockEntity(symbol: 'BH', companyName: "Banque de l'Habitat", lastPrice: 14.20, changePercent: 2.15, volume: 22100),
      StockEntity(symbol: 'TLNET', companyName: 'Telnet Holding', lastPrice: 9.85, changePercent: -1.30, volume: 5670),
      StockEntity(symbol: 'PGH', companyName: 'Poulina Group Holding', lastPrice: 12.70, changePercent: 0.80, volume: 31200),
      StockEntity(symbol: 'STAR', companyName: "Société Tunisienne d'Assurances et de Réassurance", lastPrice: 142.00, changePercent: 0.35, volume: 4560),
      StockEntity(symbol: 'ATB', companyName: 'Arab Tunisian Bank', lastPrice: 4.65, changePercent: -0.85, volume: 18900),
      StockEntity(symbol: 'ADWYA', companyName: 'Adwya', lastPrice: 5.42, changePercent: 3.20, volume: 12300),
      StockEntity(symbol: 'SOTET', companyName: 'Sotelettra', lastPrice: 3.46, changePercent: 6.12, volume: 45600),
      StockEntity(symbol: 'SAH', companyName: 'SAH Lilas', lastPrice: 8.15, changePercent: -4.20, volume: 23400),
      StockEntity(symbol: 'UADH', companyName: 'Universal Auto Distributors Holding', lastPrice: 1.78, changePercent: 5.30, volume: 67800),
      StockEntity(symbol: 'CC', companyName: 'Ciments de Carthage', lastPrice: 6.90, changePercent: -2.80, volume: 11200),
      StockEntity(symbol: 'AB', companyName: 'Amen Bank', lastPrice: 34.00, changePercent: 0.30, volume: 9800),
      StockEntity(symbol: 'ARTES', companyName: 'Artes', lastPrice: 8.40, changePercent: -1.20, volume: 7400),
      StockEntity(symbol: 'ASSAD', companyName: 'Assad', lastPrice: 8.41, changePercent: 0.95, volume: 16500),
      StockEntity(symbol: 'STB', companyName: 'Société Tunisienne de Banque', lastPrice: 6.42, changePercent: 0.62, volume: 21000),
      StockEntity(symbol: 'BNA', companyName: 'Banque Nationale Agricole', lastPrice: 10.40, changePercent: 1.10, volume: 14300),
      StockEntity(symbol: 'WIFAK', companyName: 'Wifak International Bank', lastPrice: 7.15, changePercent: -0.70, volume: 3200),
      StockEntity(symbol: 'TPR', companyName: 'TPR', lastPrice: 5.90, changePercent: 2.50, volume: 8700),
      StockEntity(symbol: 'SOPAT', companyName: 'Sopat', lastPrice: 2.38, changePercent: -3.10, volume: 5100),
    ];
  }

  Future<List<StockEntity>> getStocksBySearch(String query) async {
    final all = await getAllStocks();
    final q = query.toLowerCase();
    return all
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.companyName.toLowerCase().contains(q))
        .toList();
  }

  Future<List<IndexEntity>> getMarketIndices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      IndexEntity(
        name: 'TUNINDEX',
        value: 9245.67,
        changePercent: 0.34,
        changeValue: 31.28,
        historicalData: [9100, 9120, 9180, 9150, 9200, 9210, 9245],
      ),
      IndexEntity(
        name: 'TUNINDEX20',
        value: 4112.33,
        changePercent: -0.12,
        changeValue: -4.94,
        historicalData: [4130, 4125, 4118, 4110, 4115, 4108, 4112],
      ),
    ];
  }

  Future<List<StockEntity>> getTopGainers() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return sorted.take(5).toList();
  }

  Future<List<StockEntity>> getTopLosers() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return sorted.take(5).toList();
  }

  Future<List<StockEntity>> getMostActive() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => b.volume.compareTo(a.volume));
    return sorted.take(5).toList();
  }

  Future<StockEntity> getStockDetail(String symbol) async {
    final all = await getAllStocks();
    return all.firstWhere(
      (s) => s.symbol == symbol,
      orElse: () => const StockEntity(
        symbol: 'N/A',
        companyName: 'Inconnu',
        lastPrice: 0,
        changePercent: 0,
      ),
    );
  }
}
