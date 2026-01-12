import 'package:equatable/equatable.dart';
import '../../../domain/entities/coffee.dart';

/// Base class for all Coffee states
abstract class CoffeeState extends Equatable {
  const CoffeeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class CoffeeInitial extends CoffeeState {
  const CoffeeInitial();
}

/// State when loading initial data
class CoffeeLoading extends CoffeeState {
  const CoffeeLoading();
}

/// State when coffee data is successfully loaded
class CoffeeLoaded extends CoffeeState {
  final List<Coffee> browseCoffees;
  final List<Coffee> favorites;
  final bool isLoadingMore;

  const CoffeeLoaded({
    required this.browseCoffees,
    required this.favorites,
    this.isLoadingMore = false,
  });

  CoffeeLoaded copyWith({
    List<Coffee>? browseCoffees,
    List<Coffee>? favorites,
    bool? isLoadingMore,
  }) {
    return CoffeeLoaded(
      browseCoffees: browseCoffees ?? this.browseCoffees,
      favorites: favorites ?? this.favorites,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [browseCoffees, favorites, isLoadingMore];
}

/// State when an error occurs
class CoffeeError extends CoffeeState {
  final String message;
  final List<Coffee> browseCoffees;
  final List<Coffee> favorites;

  const CoffeeError({
    required this.message,
    this.browseCoffees = const [],
    this.favorites = const [],
  });

  @override
  List<Object?> get props => [message, browseCoffees, favorites];
}
