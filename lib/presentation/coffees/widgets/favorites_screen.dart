import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../business_logic/coffee_bloc.dart';
import '../business_logic/coffee_event.dart';
import '../business_logic/coffee_state.dart';
import '../../../domain/entities/coffee.dart';
import 'coffee_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();

    // Load favorites when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoffeeBloc>().add(const LoadFavorites());
    });
  }

  Future<void> _onRefresh() async {
    context.read<CoffeeBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 2,
      ),
      body: BlocBuilder<CoffeeBloc, CoffeeState>(
        builder: (context, state) {
          final favorites = state is CoffeeLoaded ? state.favorites : <Coffee>[];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse coffee images and add your favorites',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final coffee = favorites[index];
                return CoffeeCard(
                  coffee: coffee,
                  onFavoriteToggle: () {
                    context.read<CoffeeBloc>().add(ToggleFavorite(coffee));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
