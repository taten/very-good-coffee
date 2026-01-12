import '../../domain/entities/coffee.dart';

/// Data Transfer Object for Coffee API responses.
/// This represents the raw API structure and handles JSON serialization.
class CoffeeDto {
  final String file;

  const CoffeeDto({
    required this.file,
  });

  /// Creates a CoffeeDto from JSON API response
  factory CoffeeDto.fromJson(Map<String, dynamic> json) {
    return CoffeeDto(
      file: json['file'] as String,
    );
  }

  /// Converts to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'file': file,
    };
  }

  /// Converts DTO to domain entity
  Coffee toEntity({bool isFavorite = false}) {
    return Coffee(
      id: file.hashCode.toString(),
      imageUrl: file,
      isFavorite: isFavorite,
    );
  }

  /// Creates DTO from domain entity
  static CoffeeDto fromEntity(Coffee coffee) {
    return CoffeeDto(
      file: coffee.imageUrl,
    );
  }
}
