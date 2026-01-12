import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';

void main() {
  group('Coffee Entity', () {
    test('should create Coffee instance with required fields', () {
      const coffee = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: false,
      );

      expect(coffee.id, '123');
      expect(coffee.imageUrl, 'https://example.com/coffee.jpg');
      expect(coffee.isFavorite, false);
    });

    test('should have default isFavorite value of false', () {
      const coffee = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
      );

      expect(coffee.isFavorite, false);
    });

    test('copyWith should create new instance with updated values', () {
      const coffee = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: false,
      );

      final updatedCoffee = coffee.copyWith(isFavorite: true);

      expect(updatedCoffee.id, '123');
      expect(updatedCoffee.imageUrl, 'https://example.com/coffee.jpg');
      expect(updatedCoffee.isFavorite, true);
      expect(coffee.isFavorite, false); // Original should be unchanged
    });

    test('copyWith should keep original values when no parameters provided', () {
      const coffee = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: true,
      );

      final copiedCoffee = coffee.copyWith();

      expect(copiedCoffee.id, coffee.id);
      expect(copiedCoffee.imageUrl, coffee.imageUrl);
      expect(copiedCoffee.isFavorite, coffee.isFavorite);
    });

    test('should support value equality using Equatable', () {
      const coffee1 = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: false,
      );

      const coffee2 = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: false,
      );

      const coffee3 = Coffee(
        id: '456',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: false,
      );

      expect(coffee1, equals(coffee2));
      expect(coffee1, isNot(equals(coffee3)));
    });

    test('should have correct props for Equatable', () {
      const coffee = Coffee(
        id: '123',
        imageUrl: 'https://example.com/coffee.jpg',
        isFavorite: true,
      );

      expect(
        coffee.props,
        equals(['123', 'https://example.com/coffee.jpg', true]),
      );
    });
  });
}
