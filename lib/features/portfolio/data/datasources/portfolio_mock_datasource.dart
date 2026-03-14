import '../../../home/domain/entities/portfolio_entity.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/entities/transaction_entity.dart';

/// Source de données mock pour le Portfolio
class PortfolioMockDataSource {
  Future<PortfolioEntity> getPortfolioSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
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

  Future<List<PositionEntity>> getPositions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PositionEntity(
        symbol: 'BIAT',
        companyName: 'Banque Internationale Arabe de Tunisie',
        quantity: 50,
        avgPrice: 102.00,
        currentPrice: 108.50,
        changePercent: 1.25,
      ),
      PositionEntity(
        symbol: 'SFBT',
        companyName: 'Société Frigorifique et Brasserie de Tunis',
        quantity: 120,
        avgPrice: 20.50,
        currentPrice: 21.30,
        changePercent: -0.47,
      ),
      PositionEntity(
        symbol: 'BH',
        companyName: "Banque de l'Habitat",
        quantity: 200,
        avgPrice: 13.00,
        currentPrice: 14.20,
        changePercent: 2.15,
      ),
      PositionEntity(
        symbol: 'PGH',
        companyName: 'Poulina Group Holding',
        quantity: 150,
        avgPrice: 12.10,
        currentPrice: 12.70,
        changePercent: 0.80,
      ),
      PositionEntity(
        symbol: 'ATB',
        companyName: 'Arab Tunisian Bank',
        quantity: 500,
        avgPrice: 4.90,
        currentPrice: 4.65,
        changePercent: -0.85,
      ),
      PositionEntity(
        symbol: 'ADWYA',
        companyName: 'Adwya',
        quantity: 300,
        avgPrice: 4.80,
        currentPrice: 5.42,
        changePercent: 3.20,
      ),
    ];
  }

  Future<List<TransactionEntity>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      TransactionEntity(
        id: 'TXN001',
        symbol: 'BIAT',
        type: 'BUY',
        quantity: 20,
        price: 106.80,
        date: DateTime(2026, 2, 28),
      ),
      TransactionEntity(
        id: 'TXN002',
        symbol: 'SFBT',
        type: 'SELL',
        quantity: 30,
        price: 21.50,
        date: DateTime(2026, 2, 25),
      ),
      TransactionEntity(
        id: 'TXN003',
        symbol: 'BH',
        type: 'BUY',
        quantity: 100,
        price: 13.80,
        date: DateTime(2026, 2, 20),
      ),
      TransactionEntity(
        id: 'TXN004',
        symbol: 'PGH',
        type: 'BUY',
        quantity: 50,
        price: 12.30,
        date: DateTime(2026, 2, 15),
      ),
      TransactionEntity(
        id: 'TXN005',
        symbol: 'ATB',
        type: 'SELL',
        quantity: 200,
        price: 4.70,
        date: DateTime(2026, 2, 10),
      ),
      TransactionEntity(
        id: 'TXN006',
        symbol: 'ADWYA',
        type: 'BUY',
        quantity: 100,
        price: 5.10,
        date: DateTime(2026, 2, 5),
      ),
    ];
  }
}
