import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'FavoritePokemon.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePokemonProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Favoris")),
      body: favorites.isEmpty
          ? const Center(child: Text("Aucun favori pour l’instant."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final name = favorites[index];
                final imageUrl =
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png';

                return ListTile(
                  leading: Image.network(imageUrl, width: 50, height: 50),
                  title: Text(name),
                );
              },
            ),
    );
  }
}
