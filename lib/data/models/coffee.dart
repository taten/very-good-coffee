class Coffee {
  final String id;
  final String imageUrl;
  final bool isFavorite;

  Coffee({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
