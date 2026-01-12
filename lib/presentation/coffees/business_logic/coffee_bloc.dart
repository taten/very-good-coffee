import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/coffee_repository.dart';
import 'coffee_event.dart';
import 'coffee_state.dart';

class CoffeeBloc extends Bloc<CoffeeEvent, CoffeeState> {
  final ICoffeeRepository _repository;

  CoffeeBloc({
    required ICoffeeRepository repository,
  })  : _repository = repository,
        super(const CoffeeInitial()) {
    on<LoadBrowseCoffees>(_onLoadBrowseCoffees);
    on<LoadMoreCoffees>(_onLoadMoreCoffees);
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadBrowseCoffees(
    LoadBrowseCoffees event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(const CoffeeLoading());

    try {
      final coffees = await _repository.getMultipleCoffees(event.count);
      final favorites = await _repository.getFavorites();

      emit(CoffeeLoaded(
        browseCoffees: coffees,
        favorites: favorites,
      ));
    } catch (e) {
      emit(CoffeeError(
        message: 'Failed to load coffee images: ${e.toString()}',
      ));
    }
  }

  /// Handles loading more coffees for pagination
  Future<void> _onLoadMoreCoffees(
    LoadMoreCoffees event,
    Emitter<CoffeeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CoffeeLoaded) return;

    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newCoffees = await _repository.getMultipleCoffees(event.count);
      final updatedBrowseCoffees = [
        ...currentState.browseCoffees,
        ...newCoffees,
      ];

      emit(currentState.copyWith(
        browseCoffees: updatedBrowseCoffees,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(CoffeeError(
        message: 'Failed to load more coffee images: ${e.toString()}',
        browseCoffees: currentState.browseCoffees,
        favorites: currentState.favorites,
      ));
    }
  }

  /// Handles loading favorites
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<CoffeeState> emit,
  ) async {
    try {
      final favorites = await _repository.getFavorites();

      if (state is CoffeeLoaded) {
        final currentState = state as CoffeeLoaded;
        emit(currentState.copyWith(favorites: favorites));
      } else {
        emit(CoffeeLoaded(
          browseCoffees: const [],
          favorites: favorites,
        ));
      }
    } catch (e) {
      final currentState = state;
      emit(CoffeeError(
        message: 'Failed to load favorites: ${e.toString()}',
        browseCoffees: currentState is CoffeeLoaded ? currentState.browseCoffees : [],
        favorites: currentState is CoffeeLoaded ? currentState.favorites : [],
      ));
    }
  }

  /// Handles toggling favorite status of a coffee
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<CoffeeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CoffeeLoaded) return;

    try {
      await _repository.toggleFavorite(event.coffee);

      // Update the coffee in browse list
      final updatedBrowseCoffees = currentState.browseCoffees.map((c) {
        if (c.id == event.coffee.id) {
          return c.copyWith(isFavorite: !event.coffee.isFavorite);
        }
        return c;
      }).toList();

      // Reload favorites
      final favorites = await _repository.getFavorites();

      emit(currentState.copyWith(
        browseCoffees: updatedBrowseCoffees,
        favorites: favorites,
      ));
    } catch (e) {
      emit(CoffeeError(
        message: 'Failed to update favorite: ${e.toString()}',
        browseCoffees: currentState.browseCoffees,
        favorites: currentState.favorites,
      ));
    }
  }
}
