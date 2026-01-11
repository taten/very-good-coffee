import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/coffee_service.dart';
import '../widgets/swipeable_coffee_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Load initial coffees
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoffeeService>().loadBrowseCoffees(count: 10);
    });
  }

  void _onSwipeLeft() {
    _moveToNextCard();
  }

  void _onSwipeRight() {
    final coffeeService = context.read<CoffeeService>();
    if (_currentIndex < coffeeService.browseCoffees.length) {
      final coffee = coffeeService.browseCoffees[_currentIndex];
      coffeeService.toggleFavorite(coffee);
    }
    _moveToNextCard();
  }

  void _moveToNextCard() {
    setState(() {
      _currentIndex++;
    });

    // Load more coffees when running low
    final coffeeService = context.read<CoffeeService>();
    if (_currentIndex >= coffeeService.browseCoffees.length - 3) {
      coffeeService.loadMoreCoffees(count: 5);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentIndex = 0;
    });
    await context.read<CoffeeService>().loadBrowseCoffees(count: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Coffee'),
        elevation: 2,
      ),
      body: Consumer<CoffeeService>(
        builder: (context, coffeeService, child) {
          if (coffeeService.isLoading && coffeeService.browseCoffees.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (coffeeService.error != null &&
              coffeeService.browseCoffees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coffeeService.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_currentIndex >= coffeeService.browseCoffees.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.coffee,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No more coffees!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pull down to refresh',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Stack(
              children: [
                // Make the entire area scrollable for pull-to-refresh
                ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 100,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
                // Card stack
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Show next 2 cards behind the current one for depth
                      for (int i = _currentIndex + 2; i >= _currentIndex; i--)
                        if (i < coffeeService.browseCoffees.length)
                          Positioned(
                            top: (i - _currentIndex) * 10.0,
                            child: Transform.scale(
                              scale: 1 - (i - _currentIndex) * 0.05,
                              child: Opacity(
                                opacity: 1 - (i - _currentIndex) * 0.3,
                                child: SwipeableCoffeeCard(
                                  coffee: coffeeService.browseCoffees[i],
                                  onSwipeLeft: i == _currentIndex
                                      ? _onSwipeLeft
                                      : () {},
                                  onSwipeRight: i == _currentIndex
                                      ? _onSwipeRight
                                      : () {},
                                  isTopCard: i == _currentIndex,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                // Action buttons at the bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Skip button
                      FloatingActionButton.large(
                        heroTag: 'skip',
                        backgroundColor: Colors.white,
                        onPressed: _onSwipeLeft,
                        child: const Icon(
                          Icons.close,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                      // Favorite button
                      FloatingActionButton.large(
                        heroTag: 'favorite',
                        backgroundColor: Colors.white,
                        onPressed: _onSwipeRight,
                        child: const Icon(
                          Icons.star,
                          size: 40,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
