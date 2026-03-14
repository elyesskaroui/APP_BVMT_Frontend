import 'package:flutter_test/flutter_test.dart';
import 'package:bvmt/features/alerts/domain/entities/alert_entity.dart';

void main() {
  group('AlertEntity', () {
    test('isAbove retourne true pour condition "above"', () {
      final alert = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.isAbove, true);
    });

    test('isAbove retourne false pour condition "below"', () {
      final alert = AlertEntity(
        id: '2',
        symbol: 'SFBT',
        companyName: 'SFBT',
        targetPrice: 20.0,
        condition: 'below',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.isAbove, false);
    });

    test('conditionText retourne "Au-dessus de" pour above', () {
      final alert = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.conditionText, 'Au-dessus de');
    });

    test('conditionText retourne "En-dessous de" pour below', () {
      final alert = AlertEntity(
        id: '2',
        symbol: 'SFBT',
        companyName: 'SFBT',
        targetPrice: 20.0,
        condition: 'below',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.conditionText, 'En-dessous de');
    });

    test('formattedPrice formate correctement', () {
      final alert = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 110.50,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.formattedPrice, '110.50 TND');
    });

    test('formattedPrice ajoute les décimales si entier', () {
      final alert = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.formattedPrice, '100.00 TND');
    });

    test('isActive est true par défaut', () {
      final alert = AlertEntity(
        id: '1',
        symbol: 'TEST',
        companyName: 'Test',
        targetPrice: 50.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(alert.isActive, true);
    });

    test('Equatable : deux alertes identiques sont égales', () {
      final a1 = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      final a2 = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(a1, equals(a2));
    });

    test('Equatable : alertes différentes ne sont pas égales', () {
      final a1 = AlertEntity(
        id: '1',
        symbol: 'BIAT',
        companyName: 'BIAT',
        targetPrice: 100.0,
        condition: 'above',
        createdAt: DateTime(2026, 1, 1),
      );
      final a2 = AlertEntity(
        id: '2',
        symbol: 'SFBT',
        companyName: 'SFBT',
        targetPrice: 20.0,
        condition: 'below',
        createdAt: DateTime(2026, 1, 2),
      );
      expect(a1, isNot(equals(a2)));
    });
  });
}
