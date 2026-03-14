import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/portfolio_entity.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/entities/transaction_entity.dart';

/// États BLoC — Portfolio
abstract class PortfolioState extends Equatable {
  const PortfolioState();
  @override
  List<Object?> get props => [];
}

/// État initial
class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

/// Chargement en cours
class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

/// Données chargées
class PortfolioLoaded extends PortfolioState {
  final PortfolioEntity summary;
  final List<PositionEntity> positions;
  final List<TransactionEntity> transactions;
  final int currentTab;

  const PortfolioLoaded({
    required this.summary,
    required this.positions,
    required this.transactions,
    this.currentTab = 0,
  });

  PortfolioLoaded copyWith({
    PortfolioEntity? summary,
    List<PositionEntity>? positions,
    List<TransactionEntity>? transactions,
    int? currentTab,
  }) {
    return PortfolioLoaded(
      summary: summary ?? this.summary,
      positions: positions ?? this.positions,
      transactions: transactions ?? this.transactions,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [summary, positions, transactions, currentTab];
}

/// Erreur
class PortfolioError extends PortfolioState {
  final String message;
  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}
