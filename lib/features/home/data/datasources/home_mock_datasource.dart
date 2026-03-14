import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/portfolio_entity.dart';

/// Source de données mock pour le développement
/// Sera remplacée par les appels API réels (Finnhub / NestJS backend)
class HomeMockDataSource {
  Future<PortfolioEntity> getPortfolioSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const PortfolioEntity(
      totalValue: 18880.922,
      changePercent: 7.4,
      currency: 'TND',
      sparklineData: [
        14200, 14800, 15100, 15600, 14900, 15800,
        16200, 16800, 17100, 17500, 18200, 18880,
      ],
    );
  }

  Future<List<StockEntity>> getFavoriteStocks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      StockEntity(
        symbol: 'BIAT',
        companyName: 'Banque Internationale Arabe de Tunisie',
        lastPrice: 108.50,
        changePercent: 1.25,
        volume: 15420,
      ),
      StockEntity(
        symbol: 'SFBT',
        companyName: 'Société Frigorifique et Brasserie de Tunis',
        lastPrice: 21.30,
        changePercent: -0.47,
        volume: 8900,
      ),
      StockEntity(
        symbol: 'BH',
        companyName: 'Banque de l\'Habitat',
        lastPrice: 14.20,
        changePercent: 2.15,
        volume: 22100,
      ),
      StockEntity(
        symbol: 'TLNET',
        companyName: 'Telnet Holding',
        lastPrice: 9.85,
        changePercent: -1.30,
        volume: 5670,
      ),
      StockEntity(
        symbol: 'PGH',
        companyName: 'Poulina Group Holding',
        lastPrice: 12.70,
        changePercent: 0.80,
        volume: 31200,
      ),
      StockEntity(
        symbol: 'STAR',
        companyName: 'Société Tunisienne d\'Assurances et de Réassurance',
        lastPrice: 142.00,
        changePercent: 0.35,
        volume: 4560,
      ),
      StockEntity(
        symbol: 'ATB',
        companyName: 'Arab Tunisian Bank',
        lastPrice: 4.65,
        changePercent: -0.85,
        volume: 18900,
      ),
      StockEntity(
        symbol: 'ADWYA',
        companyName: 'Adwya',
        lastPrice: 5.42,
        changePercent: 3.20,
        volume: 12300,
      ),
    ];
  }

  Future<List<StockEntity>> getTopMovers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      StockEntity(
        symbol: 'SOTET',
        companyName: 'Sotelettra',
        lastPrice: 3.46,
        changePercent: 6.12,
        volume: 45600,
      ),
      StockEntity(
        symbol: 'SAH',
        companyName: 'SAH Lilas',
        lastPrice: 8.15,
        changePercent: -4.20,
        volume: 23400,
      ),
      StockEntity(
        symbol: 'UADH',
        companyName: 'Universal Auto Distributors Holding',
        lastPrice: 1.78,
        changePercent: 5.30,
        volume: 67800,
      ),
      StockEntity(
        symbol: 'CC',
        companyName: 'Ciments de Carthage',
        lastPrice: 6.90,
        changePercent: -2.80,
        volume: 11200,
      ),
    ];
  }

  Future<List<StockEntity>> getTickerData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      StockEntity(symbol: 'AETEC', companyName: 'Aetec', lastPrice: 9.42, changePercent: 2.10),
      StockEntity(symbol: 'AL', companyName: 'Amen Lease', lastPrice: 8.40, changePercent: -0.50),
      StockEntity(symbol: 'ALKIM', companyName: 'Alkimia', lastPrice: 5.89, changePercent: 1.80),
      StockEntity(symbol: 'AB', companyName: 'Amen Bank', lastPrice: 34.00, changePercent: 0.30),
      StockEntity(symbol: 'ARTES', companyName: 'Artes', lastPrice: 8.40, changePercent: -1.20),
      StockEntity(symbol: 'ASSAD', companyName: 'Assad', lastPrice: 8.41, changePercent: 0.95),
      StockEntity(symbol: 'AMV', companyName: 'Assurances Maghrebia Vie', lastPrice: 5.68, changePercent: -0.35),
      StockEntity(symbol: 'AST', companyName: 'Astree', lastPrice: 38.50, changePercent: 1.10),
      StockEntity(symbol: 'STB', companyName: 'Société Tunisienne de Banque', lastPrice: 6.42, changePercent: 0.62),
      StockEntity(symbol: 'SAM', companyName: 'Samama', lastPrice: 4.40, changePercent: -2.10),
    ];
  }

  Future<Map<String, dynamic>> getMarketIndices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'tunindex': {'value': 9245.67, 'change': 0.34},
      'tunindex20': {'value': 4112.33, 'change': -0.12},
    };
  }

  Future<bool> isMarketOpen() async {
    final now = DateTime.now();
    // BVMT: Lundi-Vendredi, 09:00-13:00
    if (now.weekday >= 6) return false;
    final hour = now.hour;
    // Ouvert entre 9h00 et 12h59 (ferme à 13h00)
    return hour >= 9 && hour < 13;
  }
}
