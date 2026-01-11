import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coffee.dart';

class CoffeeRemoteDataSource {
  static const String _baseUrl = 'https://coffee.alexflipnote.dev';

  Future<Coffee> fetchRandomCoffee() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imageUrl = data['file'] as String;

      // Generate a unique ID from the image URL
      final id = imageUrl.split('/').last.split('.').first;

      return Coffee(
        id: id,
        imageUrl: imageUrl,
      );
    } else {
      throw Exception('Failed to load coffee image');
    }
  }

  Future<List<Coffee>> fetchMultipleCoffees(int count) async {
    final List<Coffee> coffees = [];

    for (int i = 0; i < count; i++) {
      try {
        final coffee = await fetchRandomCoffee();
        coffees.add(coffee);
        // Small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        // Continue fetching even if one request fails
        continue;
      }
    }

    return coffees;
  }
}
