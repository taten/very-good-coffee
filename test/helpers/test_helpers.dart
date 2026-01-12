import 'package:very_good_coffee/domain/entities/coffee.dart';

/// Helper class containing commonly used test data and utilities
class TestHelpers {
  /// Creates a test coffee with default values
  static const Coffee createTestCoffee({
    String id = '123',
    String imageUrl = 'https://coffee.alexflipnote.dev/test.jpg',
    bool isFavorite = false,
  }) {
    return Coffee(
      id: id,
      imageUrl: imageUrl,
      isFavorite: isFavorite,
    );
  }

  /// Creates a list of test coffees
  static List<Coffee> createTestCoffeeList(int count, {bool isFavorite = false}) {
    return List.generate(
      count,
      (index) => Coffee(
        id: '$index',
        imageUrl: 'https://coffee.alexflipnote.dev/$index.jpg',
        isFavorite: isFavorite,
      ),
    );
  }
}
