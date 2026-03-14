import 'package:equatable/equatable.dart';

/// Entité métier — Transaction historique
class TransactionEntity extends Equatable {
  final String id;
  final String symbol;
  final String type; // 'BUY' or 'SELL'
  final int quantity;
  final double price;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
  });

  double get totalAmount => quantity * price;
  bool get isBuy => type == 'BUY';

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  List<Object?> get props => [id, symbol, type, quantity, price, date];
}
