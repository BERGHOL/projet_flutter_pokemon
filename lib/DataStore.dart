import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DataFetcher.dart';
import 'AppConst.dart';

final dataStoreProvider =
StateNotifierProvider<DataStore, DataStoreState>((ref) {
  var apiHelper = ref.watch(dataFetcherProvider);
  return DataStore(api : apiHelper);
});

class DataStoreState {
  //variables
  final List<List> chargedPokemon; //list = list avec cles (?)
  final List<List> chargedItems;
  final List<List> chargedAbilities;
  final List<List> chargedMoves;
  final List<List> chargedTypes;

  //constructeur
  DataStoreState(
      {this.chargedPokemon = AppConst.listPokemon,
        this.chargedItems = AppConst.listPokemon,
        this.chargedAbilities = AppConst.listAbilities,
        this.chargedMoves = AppConst.listMoves,
        this.chargedTypes = AppConst.listTypes});

  factory DataStoreState.init(){
    return DataStoreState();
  }

  DataStoreState copyWith({List<List>? toCopyPokemon, List<List>? toCopyItems, List<List>? toCopyAbilities, List<List>? toCopyMoves, List<List>? toCopyTypes}){
    return DataStoreState(chargedPokemon : toCopyPokemon ?? this.chargedPokemon,
        chargedItems : toCopyItems ?? this.chargedItems,
        chargedAbilities: toCopyAbilities ?? this.chargedAbilities,
        chargedMoves: toCopyMoves ?? this.chargedMoves,
        chargedTypes: toCopyTypes ?? this.chargedTypes);
  }

  DataStoreState addData({List toAddPokemon = const [], List? toAddItems, List? toAddAbilities, List? toAddMoves, List? toAddTypes}){
    this.chargedPokemon.add(toAddPokemon);
    return DataStoreState(chargedPokemon : this.chargedPokemon,
        chargedItems : this.chargedItems,
        chargedAbilities: this.chargedAbilities,
        chargedMoves: this.chargedMoves,
        chargedTypes: this.chargedTypes);
  }
}

class DataStore extends StateNotifier<DataStoreState> {
  DataStore({required this.api}) : super(DataStoreState.init()) {
    SharedPreferences.getInstance().then((prefs) {});
  }

  final DataFetcher api;

  void setPokemon(List<List> pokemons) {
    state = state.copyWith(toCopyPokemon: pokemons);
  }
  void setItems(List<List> items) {
    state = state.copyWith(toCopyItems: items);
  }
  void setAbilities(List<List> abilities) {
    state = state.copyWith(toCopyAbilities: abilities);
  }
  void setMoves(List<List> moves) {
    state = state.copyWith(toCopyMoves: moves);
  }
  void setTypes(List<List> types) {
    state = state.copyWith(toCopyTypes: types);
  }
  void addPokemon(List pokemon) {
    state = state.addData(toAddPokemon: pokemon);
  }

}