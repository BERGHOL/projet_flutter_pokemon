import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataFetcherProvider = Provider<DataFetcher>((ref) => DataFetcher());

class DataFetcher {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://pokeapi.co/api/v2/"));

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getFromFullUrl(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      print("Erreur getFromFullUrl : $e");
      return {};
    }
  }

  /// Récupère la liste des Pokémon dans un habitat spécifique (ex: 'forest', 'cave')
  Future<List<String>> getPokemonByHabitat(String habitat) async {
    try {
      final response = await _dio.get('pokemon-habitat/$habitat');
      final results = response.data['pokemon_species'] as List;
      return results.map((e) => e['name'] as String).toList();
    } catch (e) {
      print("Erreur getPokemonByHabitat : $e");
      return [];
    }
  }
}
