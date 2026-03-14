import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bvmt/shared/widgets/stock_list_item.dart';

void main() {
  group('StockListItem Widget', () {
    testWidgets('affiche le symbole et le nom', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockListItem(
              symbol: 'BIAT',
              companyName: 'Banque Internationale Arabe de Tunisie',
              price: '105.30 TND',
              changePercent: '2.45%',
              isPositive: true,
            ),
          ),
        ),
      );

      expect(find.text('BIAT'), findsOneWidget);
      expect(find.text('Banque Internationale Arabe de Tunisie'), findsOneWidget);
      expect(find.text('105.30 TND'), findsOneWidget);
      expect(find.text('+2.45%'), findsOneWidget);
    });

    testWidgets('affiche le signe - pour variation négative', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockListItem(
              symbol: 'SFBT',
              companyName: 'SFBT',
              price: '18.90 TND',
              changePercent: '-1.23%',
              isPositive: false,
            ),
          ),
        ),
      );

      expect(find.text('SFBT'), findsWidgets);
      expect(find.text('-1.23%'), findsOneWidget);
    });

    testWidgets('onTap callback est appelé', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockListItem(
              symbol: 'BIAT',
              companyName: 'BIAT',
              price: '105.30 TND',
              changePercent: '2.45%',
              isPositive: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StockListItem));
      expect(tapped, true);
    });

    testWidgets('affiche les 2 premières lettres dans l\'avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockListItem(
              symbol: 'PGH',
              companyName: 'Poulina Group Holding',
              price: '12.50 TND',
              changePercent: '0.80%',
              isPositive: true,
            ),
          ),
        ),
      );

      // L'avatar affiche les 2 premières lettres "PG"
      expect(find.text('PG'), findsOneWidget);
    });

    testWidgets('gère un symbole d\'une seule lettre', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockListItem(
              symbol: 'X',
              companyName: 'Test',
              price: '10.00 TND',
              changePercent: '0.00%',
              isPositive: true,
            ),
          ),
        ),
      );

      expect(find.text('X'), findsWidgets);
    });
  });
}
