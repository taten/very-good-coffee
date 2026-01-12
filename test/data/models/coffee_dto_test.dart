import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_coffee/data/models/coffee_dto.dart';
import 'package:very_good_coffee/domain/entities/coffee.dart';

void main() {
  group('CoffeeDto', () {
    const testFileUrl = 'https://coffee.alexflipnote.dev/abc123.jpg';

    test('should create CoffeeDto from JSON', () {
      final json = {'file': testFileUrl};

      final dto = CoffeeDto.fromJson(json);

      expect(dto.file, testFileUrl);
    });

    test('should convert CoffeeDto to JSON', () {
      const dto = CoffeeDto(file: testFileUrl);

      final json = dto.toJson();

      expect(json, {'file': testFileUrl});
    });

    test('should convert DTO to entity with default isFavorite', () {
      const dto = CoffeeDto(file: testFileUrl);

      final entity = dto.toEntity();

      expect(entity.imageUrl, 'https://corsproxy.io/?$testFileUrl');
      expect(entity.isFavorite, false);
      expect(entity.id, isNotEmpty);
    });

    test('should convert DTO to entity with custom isFavorite', () {
      const dto = CoffeeDto(file: testFileUrl);

      final entity = dto.toEntity(isFavorite: true);

      expect(entity.imageUrl, 'https://corsproxy.io/?$testFileUrl');
      expect(entity.isFavorite, true);
    });

    test('should create DTO from entity', () {
      const proxiedUrl = 'https://corsproxy.io/?$testFileUrl';
      const entity = Coffee(
        id: '123',
        imageUrl: proxiedUrl,
        isFavorite: true,
      );

      final dto = CoffeeDto.fromEntity(entity);

      expect(dto.file, testFileUrl);
    });

    test('should generate consistent ID from same URL', () {
      const dto1 = CoffeeDto(file: testFileUrl);
      const dto2 = CoffeeDto(file: testFileUrl);

      final entity1 = dto1.toEntity();
      final entity2 = dto2.toEntity();

      expect(entity1.id, entity2.id);
    });

    test('should generate different IDs for different URLs', () {
      const dto1 = CoffeeDto(file: 'https://coffee.alexflipnote.dev/abc.jpg');
      const dto2 = CoffeeDto(file: 'https://coffee.alexflipnote.dev/xyz.jpg');

      final entity1 = dto1.toEntity();
      final entity2 = dto2.toEntity();

      expect(entity1.id, isNot(entity2.id));
    });
  });
}
