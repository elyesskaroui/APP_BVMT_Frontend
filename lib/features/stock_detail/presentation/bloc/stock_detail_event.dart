import 'package:equatable/equatable.dart';

/// Événements BLoC — Stock Detail
abstract class StockDetailEvent extends Equatable {
  const StockDetailEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement des détails d'une action
class StockDetailLoadRequested extends StockDetailEvent {
  final String symbol;
  const StockDetailLoadRequested(this.symbol);

  @override
  List<Object?> get props => [symbol];
}
