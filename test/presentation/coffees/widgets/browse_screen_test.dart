import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_bloc.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_event.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_state.dart';
import 'package:very_good_coffee/presentation/coffees/widgets/browse_screen.dart';
import 'package:very_good_coffee/presentation/coffees/widgets/swipeable_coffee_card.dart';

class MockCoffeeBloc extends MockBloc<CoffeeEvent, CoffeeState>
    implements CoffeeBloc {}

void main() {
  late MockCoffeeBloc mockCoffeeBloc;

  setUp(() {
    mockCoffeeBloc = MockCoffeeBloc();
  });

  setUpAll(() {
    registerFallbackValue(const LoadBrowseCoffees());
    registerFallbackValue(const CoffeeInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CoffeeBloc>.value(
        value: mockCoffeeBloc,
        child: const BrowseScreen(),
      ),
    );
  }

  group('BrowseScreen Widget', () {
    testWidgets('should display loading indicator when state is CoffeeLoading',
        (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(const CoffeeLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when state is CoffeeError',
        (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeError(message: 'Network error'),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display swipeable cards when coffees are loaded',
        (tester) async {
      final testCoffees = [
        const Coffee(
          id: '1',
          imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
          isFavorite: false,
        ),
        const Coffee(
          id: '2',
          imageUrl: 'https://coffee.alexflipnote.dev/2.jpg',
          isFavorite: false,
        ),
      ];

      when(() => mockCoffeeBloc.state).thenReturn(
        CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SwipeableCoffeeCard), findsWidgets);
    });

    testWidgets('should display action buttons at bottom', (tester) async {
      final testCoffees = [
        const Coffee(
          id: '1',
          imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
          isFavorite: false,
        ),
      ];

      when(() => mockCoffeeBloc.state).thenReturn(
        CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Should have skip and favorite buttons
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display "No more coffees" when all cards swiped',
        (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(
        const CoffeeLoaded(
          browseCoffees: [],
          favorites: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No more coffees!'), findsOneWidget);
      expect(find.byIcon(Icons.coffee), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      when(() => mockCoffeeBloc.state).thenReturn(const CoffeeLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Browse Coffee'), findsOneWidget);
    });
  });
}
