import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';
import 'package:very_good_coffee/presentation/coffees/widgets/coffee_card.dart';

void main() {
  group('CoffeeCard Widget', () {
    const testCoffee = Coffee(
      id: '123',
      imageUrl: 'https://coffee.alexflipnote.dev/test.jpg',
      isFavorite: false,
    );

    testWidgets('should display coffee image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: testCoffee,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display favorite button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: testCoffee,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should display star_border icon when not favorited',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: testCoffee,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.star_border);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, Colors.grey);
    });

    testWidgets('should display star icon when favorited', (tester) async {
      const favoritedCoffee = Coffee(
        id: '123',
        imageUrl: 'https://coffee.alexflipnote.dev/test.jpg',
        isFavorite: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: favoritedCoffee,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.star);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, Colors.amber);
    });

    testWidgets('should call onFavoriteToggle when favorite button tapped',
        (tester) async {
      var toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: testCoffee,
              onFavoriteToggle: () {
                toggleCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('should display Card with proper styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCard(
              coffee: testCoffee,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final card = tester.widget<Card>(cardFinder);
      expect(card.clipBehavior, Clip.antiAlias);
      expect(card.elevation, 4);
    });
  });
}
