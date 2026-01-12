import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_bloc.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_event.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_state.dart';
import 'package:very_good_coffee/presentation/coffees/widgets/coffee_card.dart';
import 'package:very_good_coffee/presentation/coffees/widgets/favorites_screen.dart';

class MockCoffeeBloc extends MockBloc<CoffeeEvent, CoffeeState>
    implements CoffeeBloc {}

void main() {
  late MockCoffeeBloc mockCoffeeBloc;

  setUp(() {
    mockCoffeeBloc = MockCoffeeBloc();
  });

  setUpAll(() {
    registerFallbackValue(const LoadFavorites());
    registerFallbackValue(const CoffeeInitial());
    registerFallbackValue(
      const ToggleFavorite(
        Coffee(
          id: 'fallback',
          imageUrl: 'https://fallback.com/image.jpg',
          isFavorite: false,
        ),
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CoffeeBloc>.value(
        value: mockCoffeeBloc,
        child: const FavoritesScreen(),
      ),
    );
  }

  group('FavoritesScreen Widget', () {
    testWidgets('should display empty state when no favorites',
        (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeLoaded(
          browseCoffees: [],
          favorites: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(
        find.text('Browse coffee images and add your favorites'),
        findsOneWidget,
      );
    });

    testWidgets('should display grid of coffee cards when favorites exist',
        (tester) async {
      final testFavorites = [
        const Coffee(
          id: '1',
          imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
          isFavorite: true,
        ),
        const Coffee(
          id: '2',
          imageUrl: 'https://coffee.alexflipnote.dev/2.jpg',
          isFavorite: true,
        ),
        const Coffee(
          id: '3',
          imageUrl: 'https://coffee.alexflipnote.dev/3.jpg',
          isFavorite: true,
        ),
      ];

      when(() => mockCoffeeBloc.state).thenReturn(
        CoffeeLoaded(
          browseCoffees: const [],
          favorites: testFavorites,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(CoffeeCard), findsNWidgets(3));
    });

    testWidgets('should have app bar with title', (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeLoaded(
          browseCoffees: [],
          favorites: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('should call toggleFavorite when coffee card favorite tapped',
        (tester) async {
      const testFavorite = Coffee(
        id: '1',
        imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
        isFavorite: true,
      );

      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeLoaded(
          browseCoffees: [],
          favorites: [testFavorite],
        ),
      );
      when(() => mockCoffeeBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the favorite button on the coffee card
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      verify(() => mockCoffeeBloc.add(any(that: isA<ToggleFavorite>())))
          .called(1);
    });

    testWidgets('should display empty state when state is not CoffeeLoaded',
        (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(const CoffeeInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No favorites yet'), findsOneWidget);
    });

    testWidgets('should use GridView with 2 columns', (tester) async {
      final testFavorites = List.generate(
        4,
        (index) => Coffee(
          id: '$index',
          imageUrl: 'https://coffee.alexflipnote.dev/$index.jpg',
          isFavorite: true,
        ),
      );

      when(() => mockCoffeeBloc.state).thenReturn(
        CoffeeLoaded(
          browseCoffees: const [],
          favorites: testFavorites,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 2);
      expect(delegate.crossAxisSpacing, 8);
      expect(delegate.mainAxisSpacing, 8);
      expect(delegate.childAspectRatio, 0.75);
    });

    testWidgets('should add LoadFavorites event on init', (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeLoaded(
          browseCoffees: [],
          favorites: [],
        ),
      );
      when(() => mockCoffeeBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockCoffeeBloc.add(any(that: isA<LoadFavorites>())))
          .called(1);
    });
  });
}
