import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coffee_dto.dart';

/// Remote data source for fetching coffee images from the API.
/// Only responsible for API calls and returning DTOs.
class CoffeeRemoteDataSource {
  static const String _baseUrl = 'https://coffee.alexflipnote.dev';

  /// Fetches a single random coffee image from the API
  Future<CoffeeDto> fetchRandomCoffee() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return CoffeeDto.fromJson(data);
    } else {
      throw Exception('Failed to load coffee image: ${response.statusCode}');
    }
  }

  /// Fetches multiple random coffee images from the API
  Future<List<CoffeeDto>> fetchMultipleCoffees(int count) async {
    final List<CoffeeDto> coffees = [];

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
