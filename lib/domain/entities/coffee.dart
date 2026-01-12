import 'package:equatable/equatable.dart';

/// Domain entity representing a coffee image.
/// This is the business logic representation, separate from API models.
class Coffee extends Equatable {
  final String id;
  final String imageUrl;
  final bool isFavorite;

  const Coffee({
    required this.id,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Coffee copyWith({
    String? id,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Coffee(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, isFavorite];
}
