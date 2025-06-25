import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataFetcher.dart';

final teamProvider = StateNotifierProvider<TeamNotifier, List<String>>((ref) {
  return TeamNotifier();
});

class TeamNotifier extends StateNotifier<List<String>> {
  TeamNotifier() : super([]);

  void toggleTeam(String pokemon) {
    if (state.contains(pokemon)) {
      state = [...state]..remove(pokemon);
    } else {
      if (state.length < 6) {
        state = [...state, pokemon];
      }
    }
  }

  void clearTeam() {
    state = [];
  }

  String exportTeam() {
    return state.join(', ');
  }
}

class TeamPage extends ConsumerStatefulWidget {
  const TeamPage({super.key});

  @override
  ConsumerState<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends ConsumerState<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();

  Future<void> saveTeams(List<Map<String, dynamic>> teams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teams', jsonEncode(teams));
  }

  Future<void> saveTeam(String name, List<String> members) async {
    final prefs = await SharedPreferences.getInstance();
    final rawTeams = prefs.getString('teams');
    List<Map<String, dynamic>> teams = [];

    if (rawTeams != null) {
      try {
        final decoded = jsonDecode(rawTeams);
        if (decoded is List) {
          teams = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }

    teams.add({'name': name, 'members': members});
    await saveTeams(teams);
  }

  Future<void> showTeamsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTeams = prefs.getString('teams');
    List<Map<String, dynamic>> teams = [];

    if (rawTeams != null) {
      try {
        final decoded = jsonDecode(rawTeams);
        if (decoded is List) {
          teams = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mes Équipes"),
        content: SizedBox(
          width: double.maxFinite,
          child: teams.isEmpty
              ? const Text("Aucune équipe enregistrée.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return ListTile(
                      title: Text(team['name']),
                      subtitle: Text((team['members'] as List).join(', ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _teamNameController.text = team['name'];
                              ref.read(teamProvider.notifier).state =
                                  List<String>.from(team['members']);
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              teams.removeAt(index);
                              await saveTeams(teams);
                              Navigator.pop(context);
                              showTeamsDialog();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fetcher = ref.read(dataFetcherProvider);
    final team = ref.watch(teamProvider);
    final teamNotifier = ref.read(teamProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC0A2D),
        title: const Text('Créer son équipe', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Voir mes équipes",
            onPressed: showTeamsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: "Nom de l'équipe",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final teamName = _teamNameController.text;
                    final exported = teamNotifier.exportTeam();
                    await saveTeam(teamName, team);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Équipe créée !"),
                        content: Text("Nom: $teamName\nPokémon: $exported"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Créer"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: teamNotifier.clearTeam,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final exported = teamNotifier.exportTeam();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Équipe exportée"),
                        content: Text("Nom: ${_teamNameController.text}\nPokémon: $exported"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Exporter"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
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
                final pokemons = results.map((e) => e['name'] as String).toList();

                return ListView.builder(
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final name = pokemons[index];
                    final selected = team.contains(name);
                    final imageUrl =
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png';

                    return ListTile(
                      leading: Image.network(imageUrl, width: 40, height: 40),
                      title: Text(name),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (_) => teamNotifier.toggleTeam(name),
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
