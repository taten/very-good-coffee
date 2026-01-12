import 'package:equatable/equatable.dart';
import '../../../domain/entities/coffee.dart';

/// Base class for all Coffee events
abstract class CoffeeEvent extends Equatable {
  const CoffeeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial set of coffees for browsing
class LoadBrowseCoffees extends CoffeeEvent {
  final int count;

  const LoadBrowseCoffees({this.count = 10});

  @override
  List<Object?> get props => [count];
}

/// Event to load more coffees (pagination)
class LoadMoreCoffees extends CoffeeEvent {
  final int count;

  const LoadMoreCoffees({this.count = 5});

  @override
  List<Object?> get props => [count];
}

/// Event to load favorited coffees
class LoadFavorites extends CoffeeEvent {
  const LoadFavorites();
}

/// Event to toggle favorite status of a coffee
class ToggleFavorite extends CoffeeEvent {
  final Coffee coffee;

  const ToggleFavorite(this.coffee);

  @override
  List<Object?> get props => [coffee];
}
