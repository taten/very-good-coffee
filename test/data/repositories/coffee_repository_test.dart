import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/data/data_sources/coffee_local_data_source.dart';
import 'package:very_good_coffee/data/data_sources/coffee_remote_data_source.dart';
import 'package:very_good_coffee/data/models/coffee_dto.dart';
import 'package:very_good_coffee/data/repositories/coffee_repository.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';

class MockCoffeeRemoteDataSource extends Mock
    implements CoffeeRemoteDataSource {}

class MockCoffeeLocalDataSource extends Mock implements CoffeeLocalDataSource {}

void main() {
  late CoffeeRepository repository;
  late MockCoffeeRemoteDataSource mockRemoteDataSource;
  late MockCoffeeLocalDataSource mockLocalDataSource;

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
    mockRemoteDataSource = MockCoffeeRemoteDataSource();
    mockLocalDataSource = MockCoffeeLocalDataSource();
    repository = CoffeeRepository(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('CoffeeRepository', () {
    const testFileUrl = 'https://coffee.alexflipnote.dev/test.jpg';
    const testDto = CoffeeDto(file: testFileUrl);

    group('getRandomCoffee', () {
      test('should return coffee with favorite status from local storage',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchRandomCoffee())
            .thenAnswer((_) async => testDto);
        when(() => mockLocalDataSource.isFavorite(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.getRandomCoffee();

        // Assert
        expect(result.imageUrl, 'https://corsproxy.io/?$testFileUrl');
        expect(result.isFavorite, true);
        verify(() => mockRemoteDataSource.fetchRandomCoffee()).called(1);
        verify(() => mockLocalDataSource.isFavorite(any())).called(1);
      });

      test('should return coffee with isFavorite false when not favorited',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchRandomCoffee())
            .thenAnswer((_) async => testDto);
        when(() => mockLocalDataSource.isFavorite(any()))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.getRandomCoffee();

        // Assert
        expect(result.isFavorite, false);
      });

      test('should throw exception when remote data source fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchRandomCoffee())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getRandomCoffee(),
          throwsException,
        );
      });
    });

    group('getMultipleCoffees', () {
      test('should return list of coffees with favorite status', () async {
        // Arrange
        final testDtos = [
          const CoffeeDto(file: 'https://corsproxy.io/?https://coffee.alexflipnote.dev/1.jpg'),
          const CoffeeDto(file: 'https://corsproxy.io/?https://coffee.alexflipnote.dev/2.jpg'),
          const CoffeeDto(file: 'https://corsproxy.io/?https://coffee.alexflipnote.dev/3.jpg'),
        ];

        when(() => mockRemoteDataSource.fetchMultipleCoffees(3))
            .thenAnswer((_) async => testDtos);
        when(() => mockLocalDataSource.isFavorite(any()))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.getMultipleCoffees(3);

        // Assert
        expect(result.length, 3);
        expect(result[0].imageUrl, 'https://corsproxy.io/?${testDtos[0].file}');
        expect(result[1].imageUrl, 'https://corsproxy.io/?${testDtos[1].file}');
        expect(result[2].imageUrl, 'https://corsproxy.io/?${testDtos[2].file}');
        verify(() => mockRemoteDataSource.fetchMultipleCoffees(3)).called(1);
        verify(() => mockLocalDataSource.isFavorite(any())).called(3);
      });

      test('should check favorite status for each coffee', () async {
        // Arrange
        final testDtos = [
          const CoffeeDto(file: 'https://coffee.alexflipnote.dev/1.jpg'),
          const CoffeeDto(file: 'https://coffee.alexflipnote.dev/2.jpg'),
        ];

        when(() => mockRemoteDataSource.fetchMultipleCoffees(2))
            .thenAnswer((_) async => testDtos);

        // First coffee is favorited, second is not
        var callCount = 0;
        when(() => mockLocalDataSource.isFavorite(any())).thenAnswer((_) async {
          callCount++;
          return callCount == 1;
        });

        // Act
        final result = await repository.getMultipleCoffees(2);

        // Assert
        expect(result[0].isFavorite, true);
        expect(result[1].isFavorite, false);
      });
    });

    group('getFavorites', () {
      test('should return favorited coffees from local data source', () async {
        // Arrange
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
        ];

        when(() => mockLocalDataSource.getFavorites())
            .thenAnswer((_) async => testFavorites);

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, testFavorites);
        verify(() => mockLocalDataSource.getFavorites()).called(1);
      });

      test('should return empty list when no favorites', () async {
        // Arrange
        when(() => mockLocalDataSource.getFavorites())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('toggleFavorite', () {
      test('should remove favorite when coffee is favorited', () async {
        // Arrange
        const coffee = Coffee(
          id: '123',
          imageUrl: testFileUrl,
          isFavorite: true,
        );

        when(() => mockLocalDataSource.removeFavorite(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.toggleFavorite(coffee);

        // Assert
        verify(() => mockLocalDataSource.removeFavorite('123')).called(1);
        verifyNever(() => mockLocalDataSource.saveFavorite(any()));
      });

      test('should add favorite when coffee is not favorited', () async {
        // Arrange
        const coffee = Coffee(
          id: '123',
          imageUrl: testFileUrl,
          isFavorite: false,
        );

        when(() => mockLocalDataSource.saveFavorite(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.toggleFavorite(coffee);

        // Assert
        verify(() => mockLocalDataSource.saveFavorite(coffee)).called(1);
        verifyNever(() => mockLocalDataSource.removeFavorite(any()));
      });
    });
  });
}
