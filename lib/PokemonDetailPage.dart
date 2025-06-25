import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'DataFetcher.dart';

class PokemonDetailPage extends ConsumerWidget {
  final String pokemonName;
  final int index;

  const PokemonDetailPage({super.key, required this.pokemonName, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetcher = ref.read(dataFetcherProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC0A2D),
        title: Text(
          pokemonName.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: fetcher.get('pokemon/$pokemonName'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$index.png';

          final types = (data['types'] as List).map((e) => e['type']['name']).join(', ');
          final abilities = (data['abilities'] as List).map((e) => e['ability']['name']).join(', ');
          final moves = (data['moves'] as List)
              .take(5)
              .map((e) => e['move']['name'])
              .join(', ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(imageUrl, width: 120, height: 120),
                const SizedBox(height: 16),
                infoTile(Icons.info, "ID", "${data['id']}"),
                infoTile(Icons.height, "Taille", "${data['height']}"),
                infoTile(Icons.line_weight, "Poids", "${data['weight']}"),
                infoTile(Icons.category, "Types", types),
                infoTile(Icons.flash_on, "Talents", abilities),
                infoTile(Icons.local_fire_department, "Attaques", moves),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
