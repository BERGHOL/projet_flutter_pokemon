import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'DataFetcher.dart';
import 'PokemonDetails.dart';
import 'FavoritesPage.dart';
import 'TeamPage.dart';
import 'HabitatMapPage.dart';

final favoritePokemonProvider = StateProvider<List<String>>((ref) => []);

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final fetcher = ref.read(dataFetcherProvider);
    final favorites = ref.watch(favoritePokemonProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC0A2D),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Favoris',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.groups, color: Colors.white),
            tooltip: 'Équipes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeamPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: 'Carte des habitats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitatMapPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(
                hintText: "Rechercher un Pokémon...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetcher.get("pokemon?limit=151"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Erreur de chargement"));
                }

                final results = snapshot.data!['results'] as List;
                final pokemons = results
                    .where((e) => (e['name'] as String).contains(searchQuery))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = pokemons[index];
                    final name = pokemon['name'];
                    final originalIndex = results.indexWhere((e) => e['name'] == name);
                    final imageUrl =
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${originalIndex + 1}.png';
                    final isFavorite = favorites.contains(name);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PokemonDetails(name: name)),
                      ),
                      child: Card(
                        color: const Color(0xFFDC0A2D).withOpacity(0.85),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(imageUrl, height: 60),
                                  const SizedBox(height: 8),
                                  Text(name, style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  final list = [...favorites];
                                  if (isFavorite) {
                                    list.remove(name);
                                  } else {
                                    list.add(name);
                                  }
                                  ref.read(favoritePokemonProvider.notifier).state = list;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}