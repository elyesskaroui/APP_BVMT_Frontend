import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/stock_entity.dart';

/// États BLoC — Stock Detail
abstract class StockDetailState extends Equatable {
  const StockDetailState();
  @override
  List<Object?> get props => [];
}

class StockDetailInitial extends StockDetailState {
  const StockDetailInitial();
}

class StockDetailLoading extends StockDetailState {
  const StockDetailLoading();
}

class StockDetailLoaded extends StockDetailState {
  final StockEntity stock;
  final List<double> chartData;
  final String selectedPeriod;

  const StockDetailLoaded({
    required this.stock,
    required this.chartData,
    this.selectedPeriod = '1M',
  });

  StockDetailLoaded copyWith({
    StockEntity? stock,
    List<double>? chartData,
    String? selectedPeriod,
  }) {
    return StockDetailLoaded(
      stock: stock ?? this.stock,
      chartData: chartData ?? this.chartData,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [stock, chartData, selectedPeriod];
}

class StockDetailError extends StockDetailState {
  final String message;
  const StockDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
