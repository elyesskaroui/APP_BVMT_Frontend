import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bvmt/features/alerts/presentation/bloc/alerts_bloc.dart';
import 'package:bvmt/features/alerts/presentation/bloc/alerts_event.dart';
import 'package:bvmt/features/alerts/presentation/bloc/alerts_state.dart';
import 'package:bvmt/features/alerts/domain/entities/alert_entity.dart';

void main() {
  group('AlertsBloc', () {
    late AlertsBloc bloc;

    setUp(() {
      bloc = AlertsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('état initial est AlertsInitial', () {
      expect(bloc.state, const AlertsInitial());
    });

    blocTest<AlertsBloc, AlertsState>(
      'émet [AlertsLoading, AlertsLoaded] lors du chargement',
      build: () => AlertsBloc(),
      act: (bloc) => bloc.add(const AlertsLoadRequested()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const AlertsLoading(),
        isA<AlertsLoaded>().having(
          (s) => s.alerts.length,
          'nombre d\'alertes',
          4,
        ),
      ],
    );

    blocTest<AlertsBloc, AlertsState>(
      'les alertes chargées contiennent BIAT, SFBT, PGH, STAR',
      build: () => AlertsBloc(),
      act: (bloc) => bloc.add(const AlertsLoadRequested()),
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        final state = bloc.state as AlertsLoaded;
        final symbols = state.alerts.map((a) => a.symbol).toList();
        expect(symbols, containsAll(['BIAT', 'SFBT', 'PGH', 'STAR']));
      },
    );

    blocTest<AlertsBloc, AlertsState>(
      'AlertToggled inverse le statut actif d\'une alerte',
      build: () => AlertsBloc(),
      seed: () => AlertsLoaded(alerts: [
        AlertEntity(
          id: 'ALR001',
          symbol: 'BIAT',
          companyName: 'BIAT',
          targetPrice: 110.0,
          condition: 'above',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
      act: (bloc) => bloc.add(const AlertToggled('ALR001')),
      expect: () => [
        isA<AlertsLoaded>().having(
          (s) => s.alerts.first.isActive,
          'isActive',
          false,
        ),
      ],
    );

    blocTest<AlertsBloc, AlertsState>(
      'AlertDeleted supprime l\'alerte de la liste',
      build: () => AlertsBloc(),
      seed: () => AlertsLoaded(alerts: [
        AlertEntity(
          id: 'ALR001',
          symbol: 'BIAT',
          companyName: 'BIAT',
          targetPrice: 110.0,
          condition: 'above',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        AlertEntity(
          id: 'ALR002',
          symbol: 'SFBT',
          companyName: 'SFBT',
          targetPrice: 20.0,
          condition: 'below',
          isActive: true,
          createdAt: DateTime(2026, 1, 2),
        ),
      ]),
      act: (bloc) => bloc.add(const AlertDeleted('ALR001')),
      expect: () => [
        isA<AlertsLoaded>()
            .having((s) => s.alerts.length, 'count', 1)
            .having((s) => s.alerts.first.symbol, 'symbol', 'SFBT'),
      ],
    );

    blocTest<AlertsBloc, AlertsState>(
      'AlertCreated ajoute une alerte en tête de liste',
      build: () => AlertsBloc(),
      seed: () => AlertsLoaded(alerts: [
        AlertEntity(
          id: 'ALR001',
          symbol: 'BIAT',
          companyName: 'BIAT',
          targetPrice: 110.0,
          condition: 'above',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
      act: (bloc) => bloc.add(const AlertCreated(
        symbol: 'ATB',
        targetPrice: 5.50,
        condition: 'below',
      )),
      expect: () => [
        isA<AlertsLoaded>()
            .having((s) => s.alerts.length, 'count', 2)
            .having((s) => s.alerts.first.symbol, 'premier', 'ATB')
            .having((s) => s.alerts.first.isActive, 'active', true)
            .having((s) => s.alerts.first.condition, 'condition', 'below'),
      ],
    );

    blocTest<AlertsBloc, AlertsState>(
      'AlertToggled ne fait rien si état n\'est pas AlertsLoaded',
      build: () => AlertsBloc(),
      act: (bloc) => bloc.add(const AlertToggled('ALR001')),
      expect: () => [],
    );

    blocTest<AlertsBloc, AlertsState>(
      'AlertDeleted ne fait rien si état n\'est pas AlertsLoaded',
      build: () => AlertsBloc(),
      act: (bloc) => bloc.add(const AlertDeleted('ALR001')),
      expect: () => [],
    );
  });
}
