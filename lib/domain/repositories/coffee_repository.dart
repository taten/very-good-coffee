import '../entities/coffee.dart';

/// Abstract repository interface defining coffee data operations.
/// This belongs to the domain layer and defines what operations are available.
/// The actual implementation will be in the data layer.
abstract class ICoffeeRepository {
  /// Fetches a single random coffee image
  Future<Coffee> getRandomCoffee();

  /// Fetches multiple random coffee images
  Future<List<Coffee>> getMultipleCoffees(int count);

  /// Fetches all favorited coffees from local storage
  Future<List<Coffee>> getFavorites();

  /// Toggles the favorite status of a coffee
  Future<void> toggleFavorite(Coffee coffee);
}
