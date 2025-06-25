import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'DataFetcher.dart';

class PokemonDetails extends ConsumerWidget {
  final String name;

  const PokemonDetails({super.key, required this.name});

  Color typeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber;
      case 'psychic':
        return Colors.purple;
      case 'rock':
        return Colors.brown;
      case 'ground':
        return Colors.orange;
      case 'poison':
        return Colors.deepPurple;
      case 'bug':
        return Colors.lightGreen;
      case 'flying':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetcher = ref.read(dataFetcherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(name.toUpperCase()),
        backgroundColor: const Color(0xFFDC0A2D),
      ),
      body: FutureBuilder(
        future: fetcher.get('pokemon/$name'),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) {
            return const Center(child: Text('Erreur de chargement'));
          }

          final data = snap.data!;
          final speciesUrl = data['species']['url'] as String;

          return FutureBuilder(
            future: Future.wait([
              fetcher.get('pokemon/$name'),
              fetcher.getFromFullUrl(speciesUrl),
            ]),
            builder: (ctx2, snap2) {
              if (snap2.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap2.hasData) {
                return const Center(child: Text('Erreur de loading'));
              }

              final speciesData = snap2.data![1] as Map<String, dynamic>;
              final evoChainUrl = speciesData['evolution_chain']['url'] as String;

              return FutureBuilder(
                future: fetcher.getFromFullUrl(evoChainUrl),
                builder: (ctx3, snap3) {
                  if (snap3.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap3.hasData) {
                    return const Center(child: Text('Évolution non trouvée'));
                  }

                  List<String> evoList = [];
                  void traverse(node) {
                    evoList.add(node['species']['name']);
                    final evolveTo = node['evolves_to'] as List;
                    if (evolveTo.isNotEmpty) {
                      traverse(evolveTo[0]);
                    }
                  }
                  traverse(snap3.data!['chain']);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.network(
                            data['sprites']['front_default'],
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: (data['types'] as List)
                              .map((t) => t['type']['name'] as String)
                              .map((type) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: typeColor(type),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(type, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        ...((data['stats'] as List).map((s) {
                          return Text('${s['stat']['name']}: ${s['base_stat']}');
                        }).toList()),
                        const SizedBox(height: 16),
                        const Text('Talents :', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...((data['abilities'] as List).map((a) {
                          return Text(a['ability']['name'] as String);
                        }).toList()),
                        const SizedBox(height: 16),
                        const Text('Attaques :', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...((data['moves'] as List).take(5).map((m) {
                          return Text((m['move']['name']) as String);
                        }).toList()),
                        const SizedBox(height: 16),
                        const Text('Évolution :', style: TextStyle(fontWeight: FontWeight.bold)),
                        FutureBuilder(
                          future: Future.wait(
                            evoList.map((evoName) => fetcher.get('pokemon/$evoName')).toList(),
                          ),
                          builder: (context, evoSnap) {
                            if (evoSnap.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!evoSnap.hasData) {
                              return const Text('Erreur évolution');
                            }

                            final evoDataList = evoSnap.data!;
                            return Wrap(
                              spacing: 8,
                              children: evoDataList.map((evoData) {
                                final id = evoData['id'];
                                final name = evoData['name'];
                                final img =
                                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
                                return Column(
                                  children: [
                                    Image.network(img, height: 60),
                                    Text(name),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
