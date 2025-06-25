import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'DataFetcher.dart';

class HabitatMapPage extends ConsumerWidget {
  const HabitatMapPage({super.key});

  Future<void> _showPokemonList(BuildContext context, WidgetRef ref, String habitat) async {
    final fetcher = ref.read(dataFetcherProvider);
    final pokemons = await fetcher.getPokemonByHabitat(habitat);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pokémon du $habitat'),
        content: pokemons.isEmpty
            ? const Text("Aucun Pokémon ou erreur")
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pokemons.length,
                  itemBuilder: (_, i) => ListTile(title: Text(pokemons[i])),
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des habitats"),
        backgroundColor: const Color(0xFFDC0A2D),
      ),
      body: InteractiveViewer(
        child: Stack(
          children: [
            Image.asset('assets/map.png'),

            // Zone Désert
            Positioned(
              left: 650,
              top: 90,
              child: GestureDetector(
                onTap: () => _showPokemonList(context, ref, "desert"),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
            ),

            // Zone Forêt
            Positioned(
              left: 300,
              top: 100,
              child: GestureDetector(
                onTap: () => _showPokemonList(context, ref, "forest"),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.green.withOpacity(0.7),
                ),
              ),
            ),

            // Zone Grotte
            Positioned(
              left: 480,
              top: 300,
              child: GestureDetector(
                onTap: () => _showPokemonList(context, ref, "cave"),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.blue.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
