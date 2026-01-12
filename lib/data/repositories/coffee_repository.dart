import '../../domain/entities/coffee.dart';
import '../../domain/repositories/coffee_repository.dart';
import '../data_sources/coffee_local_data_source.dart';
import '../data_sources/coffee_remote_data_source.dart';

/// Implementation of CoffeeRepository.
/// Orchestrates data sources and converts DTOs to domain entities.
class CoffeeRepository implements ICoffeeRepository {
  final CoffeeRemoteDataSource _remoteDataSource;
  final CoffeeLocalDataSource _localDataSource;

  CoffeeRepository({
    required CoffeeRemoteDataSource remoteDataSource,
    required CoffeeLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Coffee> getRandomCoffee() async {
    final dto = await _remoteDataSource.fetchRandomCoffee();
    final coffee = dto.toEntity();
    final isFavorite = await _localDataSource.isFavorite(coffee.id);
    return coffee.copyWith(isFavorite: isFavorite);
  }

  @override
  Future<List<Coffee>> getMultipleCoffees(int count) async {
    final dtos = await _remoteDataSource.fetchMultipleCoffees(count);

    // Convert DTOs to entities and check favorite status
    final coffees = <Coffee>[];
    for (final dto in dtos) {
      final coffee = dto.toEntity();
      final isFavorite = await _localDataSource.isFavorite(coffee.id);
      coffees.add(coffee.copyWith(isFavorite: isFavorite));
    }

    return coffees;
  }

  @override
  Future<List<Coffee>> getFavorites() async {
    return await _localDataSource.getFavorites();
  }

  @override
  Future<void> toggleFavorite(Coffee coffee) async {
    if (coffee.isFavorite) {
      await _localDataSource.removeFavorite(coffee.id);
    } else {
      await _localDataSource.saveFavorite(coffee);
    }
  }
}
