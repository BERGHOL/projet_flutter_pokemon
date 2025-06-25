import 'package:appli_perso/DataFetcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'DataStore.dart';
import 'DataFetcher.dart';

Future<String> fetchSingleData(DataStore store, String request, List<String> path) async {
  final data = await store.api.get(request);
  var transition = data;
  for (int i = 0; i < path.length; i++) {
    transition = transition[path[i]];
  }
  print(transition);
  return transition as String;
}

class PokemonCard extends ConsumerWidget {
  const PokemonCard({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final DataStoreState state = ref.watch(dataStoreProvider);
    final DataStore store = ref.read(dataStoreProvider.notifier);


    return Center(
      child: Container(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<String>(
              future: fetchSingleData(store, 'pokemon/303', ['sprites', 'front_default']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 120,
                    width: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return SizedBox(
                    height: 120,
                    width: 200,
                    child: Center(child: Icon(Icons.error)),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      snapshot.data!,
                      height: 120,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Titre de la carte',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}