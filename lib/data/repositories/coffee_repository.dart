import '../models/coffee.dart';
import 'coffee_remote_data_source.dart';
import 'coffee_local_data_source.dart';

class CoffeeRepository {
  final CoffeeRemoteDataSource _remoteDataSource;
  final CoffeeLocalDataSource _localDataSource;

  CoffeeRepository({
    CoffeeRemoteDataSource? remoteDataSource,
    CoffeeLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? CoffeeRemoteDataSource(),
        _localDataSource = localDataSource ?? CoffeeLocalDataSource();

  Future<Coffee> getRandomCoffee() async {
    final coffee = await _remoteDataSource.fetchRandomCoffee();
    final isFavorite = await _localDataSource.isFavorite(coffee.id);
    return coffee.copyWith(isFavorite: isFavorite);
  }

  Future<List<Coffee>> getMultipleCoffees(int count) async {
    final coffees = await _remoteDataSource.fetchMultipleCoffees(count);

    // Check favorite status for each coffee
    final coffeesWithFavorites = <Coffee>[];
    for (final coffee in coffees) {
      final isFavorite = await _localDataSource.isFavorite(coffee.id);
      coffeesWithFavorites.add(coffee.copyWith(isFavorite: isFavorite));
    }

    return coffeesWithFavorites;
  }

  Future<List<Coffee>> getFavorites() async {
    return await _localDataSource.getFavorites();
  }

  Future<void> toggleFavorite(Coffee coffee) async {
    if (coffee.isFavorite) {
      await _localDataSource.removeFavorite(coffee.id);
    } else {
      await _localDataSource.saveFavorite(coffee);
    }
  }
}
