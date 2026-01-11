import 'package:flutter/foundation.dart';
import '../data/models/coffee.dart';
import '../data/repositories/coffee_repository.dart';

class CoffeeService extends ChangeNotifier {
  final CoffeeRepository _repository;

  List<Coffee> _browseCoffees = [];
  List<Coffee> _favorites = [];
  bool _isLoading = false;
  String? _error;

  CoffeeService({CoffeeRepository? repository})
      : _repository = repository ?? CoffeeRepository();

  List<Coffee> get browseCoffees => _browseCoffees;
  List<Coffee> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBrowseCoffees({int count = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _browseCoffees = await _repository.getMultipleCoffees(count);
      _error = null;
    } catch (e) {
      _error = 'Failed to load coffee images: ${e.toString()}';
      _browseCoffees = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCoffees({int count = 5}) async {
    try {
      final newCoffees = await _repository.getMultipleCoffees(count);
      _browseCoffees.addAll(newCoffees);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load more coffee images: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    try {
      _favorites = await _repository.getFavorites();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorites: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Coffee coffee) async {
    try {
      await _repository.toggleFavorite(coffee);

      // Update the coffee in browse list
      final browseIndex = _browseCoffees.indexWhere((c) => c.id == coffee.id);
      if (browseIndex != -1) {
        _browseCoffees[browseIndex] = _browseCoffees[browseIndex]
            .copyWith(isFavorite: !coffee.isFavorite);
      }

      // Reload favorites
      await loadFavorites();

      _error = null;
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
