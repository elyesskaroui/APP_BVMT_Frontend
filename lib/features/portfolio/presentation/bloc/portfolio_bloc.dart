import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/portfolio_usecases.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

/// BLoC Portfolio — gère la logique métier de l'écran Portefeuille
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolioDetail getPortfolioDetail;
  final GetPositions getPositions;
  final GetTransactions getTransactions;

  PortfolioBloc({
    required this.getPortfolioDetail,
    required this.getPositions,
    required this.getTransactions,
  }) : super(const PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoadRequested);
    on<PortfolioRefreshRequested>(_onRefreshRequested);
    on<PortfolioTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    PortfolioLoadRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    PortfolioRefreshRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onTabChanged(
    PortfolioTabChanged event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state is PortfolioLoaded) {
      final current = state as PortfolioLoaded;
      emit(current.copyWith(currentTab: event.tabIndex));
    }
  }

  Future<void> _loadData(Emitter<PortfolioState> emit) async {
    try {
      final results = await Future.wait([
        getPortfolioDetail(),
        getPositions(),
        getTransactions(),
      ]);

      emit(PortfolioLoaded(
        summary: results[0] as dynamic,
        positions: results[1] as dynamic,
        transactions: results[2] as dynamic,
      ));
    } catch (e) {
      emit(PortfolioError(
          'Impossible de charger le portefeuille: ${e.toString()}'));
    }
  }
}
