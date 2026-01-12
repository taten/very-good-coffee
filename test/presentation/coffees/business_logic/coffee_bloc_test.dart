import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';
import 'package:very_good_coffee/domain/repositories/coffee_repository.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_bloc.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_event.dart';
import 'package:very_good_coffee/presentation/coffees/business_logic/coffee_state.dart';

class MockCoffeeRepository extends Mock implements ICoffeeRepository {}

void main() {
  late CoffeeBloc coffeeBloc;
  late MockCoffeeRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const Coffee(
        id: 'fallback',
        imageUrl: 'https://fallback.com/image.jpg',
        isFavorite: false,
      ),
    );
  });

  setUp(() {
    mockRepository = MockCoffeeRepository();
    coffeeBloc = CoffeeBloc(repository: mockRepository);
  });

  tearDown(() {
    coffeeBloc.close();
  });

  group('CoffeeBloc', () {
    const testCoffee = Coffee(
      id: '1',
      imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
      isFavorite: false,
    );

    final testCoffees = [
      testCoffee,
      const Coffee(
        id: '2',
        imageUrl: 'https://coffee.alexflipnote.dev/2.jpg',
        isFavorite: false,
      ),
    ];

    test('initial state is CoffeeInitial', () {
      expect(coffeeBloc.state, equals(const CoffeeInitial()));
    });

    group('LoadBrowseCoffees', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoading, CoffeeLoaded] when successful',
        build: () {
          when(() => mockRepository.getMultipleCoffees(any()))
              .thenAnswer((_) async => testCoffees);
          when(() => mockRepository.getFavorites())
              .thenAnswer((_) async => []);
          return coffeeBloc;
        },
        act: (bloc) => bloc.add(const LoadBrowseCoffees(count: 10)),
        expect: () => [
          const CoffeeLoading(),
          CoffeeLoaded(
            browseCoffees: testCoffees,
            favorites: const [],
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getMultipleCoffees(10)).called(1);
          verify(() => mockRepository.getFavorites()).called(1);
        },
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoading, CoffeeError] when repository throws error',
        build: () {
          when(() => mockRepository.getMultipleCoffees(any()))
              .thenThrow(Exception('Network error'));
          return coffeeBloc;
        },
        act: (bloc) => bloc.add(const LoadBrowseCoffees(count: 10)),
        expect: () => [
          const CoffeeLoading(),
          isA<CoffeeError>()
              .having(
                (state) => state.message,
                'message',
                contains('Failed to load coffee images'),
              )
              .having(
                (state) => state.browseCoffees,
                'browseCoffees',
                isEmpty,
              ),
        ],
      );
    });

    group('LoadMoreCoffees', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'adds new coffees to existing list',
        build: () {
          when(() => mockRepository.getMultipleCoffees(any()))
              .thenAnswer((_) async => [testCoffee]);
          return coffeeBloc;
        },
        seed: () => CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
        act: (bloc) => bloc.add(const LoadMoreCoffees(count: 5)),
        expect: () => [
          CoffeeLoaded(
            browseCoffees: testCoffees,
            favorites: const [],
            isLoadingMore: true,
          ),
          CoffeeLoaded(
            browseCoffees: [...testCoffees, testCoffee],
            favorites: const [],
            isLoadingMore: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getMultipleCoffees(5)).called(1);
        },
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'does nothing when state is not CoffeeLoaded',
        build: () => coffeeBloc,
        seed: () => const CoffeeInitial(),
        act: (bloc) => bloc.add(const LoadMoreCoffees(count: 5)),
        expect: () => [],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits CoffeeError when loading more fails',
        build: () {
          when(() => mockRepository.getMultipleCoffees(any()))
              .thenThrow(Exception('Network error'));
          return coffeeBloc;
        },
        seed: () => CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
        act: (bloc) => bloc.add(const LoadMoreCoffees(count: 5)),
        expect: () => [
          CoffeeLoaded(
            browseCoffees: testCoffees,
            favorites: const [],
            isLoadingMore: true,
          ),
          isA<CoffeeError>()
              .having(
                (state) => state.message,
                'message',
                contains('Failed to load more coffee images'),
              )
              .having(
                (state) => state.browseCoffees,
                'browseCoffees',
                testCoffees,
              ),
        ],
      );
    });

    group('LoadFavorites', () {
      final testFavorites = [
        const Coffee(
          id: '1',
          imageUrl: 'https://coffee.alexflipnote.dev/1.jpg',
          isFavorite: true,
        ),
      ];

      blocTest<CoffeeBloc, CoffeeState>(
        'updates favorites in CoffeeLoaded state',
        build: () {
          when(() => mockRepository.getFavorites())
              .thenAnswer((_) async => testFavorites);
          return coffeeBloc;
        },
        seed: () => CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
        act: (bloc) => bloc.add(const LoadFavorites()),
        expect: () => [
          CoffeeLoaded(
            browseCoffees: testCoffees,
            favorites: testFavorites,
          ),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'creates CoffeeLoaded state when current state is not CoffeeLoaded',
        build: () {
          when(() => mockRepository.getFavorites())
              .thenAnswer((_) async => testFavorites);
          return coffeeBloc;
        },
        seed: () => const CoffeeInitial(),
        act: (bloc) => bloc.add(const LoadFavorites()),
        expect: () => [
          CoffeeLoaded(
            browseCoffees: const [],
            favorites: testFavorites,
          ),
        ],
      );
    });

    group('ToggleFavorite', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'toggles favorite status and updates lists',
        build: () {
          when(() => mockRepository.toggleFavorite(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getFavorites())
              .thenAnswer((_) async => [testCoffee.copyWith(isFavorite: true)]);
          return coffeeBloc;
        },
        seed: () => CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
        act: (bloc) => bloc.add(ToggleFavorite(testCoffee)),
        expect: () => [
          isA<CoffeeLoaded>()
              .having(
                (state) => state.browseCoffees.first.isFavorite,
                'first coffee isFavorite',
                true,
              )
              .having(
                (state) => state.favorites.length,
                'favorites length',
                1,
              ),
        ],
        verify: (_) {
          verify(() => mockRepository.toggleFavorite(testCoffee)).called(1);
          verify(() => mockRepository.getFavorites()).called(1);
        },
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'does nothing when state is not CoffeeLoaded',
        build: () => coffeeBloc,
        seed: () => const CoffeeInitial(),
        act: (bloc) => bloc.add(ToggleFavorite(testCoffee)),
        expect: () => [],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits CoffeeError when toggle fails',
        build: () {
          when(() => mockRepository.toggleFavorite(any()))
              .thenThrow(Exception('Storage error'));
          return coffeeBloc;
        },
        seed: () => CoffeeLoaded(
          browseCoffees: testCoffees,
          favorites: const [],
        ),
        act: (bloc) => bloc.add(ToggleFavorite(testCoffee)),
        expect: () => [
          isA<CoffeeError>()
              .having(
                (state) => state.message,
                'message',
                contains('Failed to update favorite'),
              )
              .having(
                (state) => state.browseCoffees,
                'browseCoffees',
                testCoffees,
              ),
        ],
      );
    });
  });
}
