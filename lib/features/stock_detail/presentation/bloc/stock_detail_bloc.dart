import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../market/data/datasources/market_mock_datasource.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

/// BLoC Stock Detail — charge les détails + génère données graphique
class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final MarketMockDataSource dataSource;

  StockDetailBloc({required this.dataSource}) : super(const StockDetailInitial()) {
    on<StockDetailLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    StockDetailLoadRequested event,
    Emitter<StockDetailState> emit,
  ) async {
    emit(const StockDetailLoading());
    try {
      final stock = await dataSource.getStockDetail(event.symbol);

      // Générer des données de graphique mock (30 points)
      final random = Random(stock.symbol.hashCode);
      final basePrice = stock.lastPrice;
      final chartData = List.generate(30, (i) {
        return basePrice * (0.92 + random.nextDouble() * 0.16);
      });
      // Le dernier point est le prix actuel
      chartData[chartData.length - 1] = stock.lastPrice;

      emit(StockDetailLoaded(
        stock: stock,
        chartData: chartData,
      ));
    } catch (e) {
      emit(StockDetailError('Impossible de charger les détails: ${e.toString()}'));
    }
  }
}
