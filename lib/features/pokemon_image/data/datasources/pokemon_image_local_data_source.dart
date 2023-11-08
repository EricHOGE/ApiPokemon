// Importation des dépendances nécessaires.
import 'dart:convert'; // Pour la conversion de données JSON.

import 'package:shared_preferences/shared_preferences.dart'; // Pour le stockage de données clé-valeur localement.

// Importation des fichiers du projet pour la gestion des exceptions et le modèle de données.
import '../../../../../core/errors/exceptions.dart'; // Pour gérer les exceptions personnalisées.
import '../models/pokemon_image_model.dart'; // Pour le modèle de données des images de Pokémon.



// #############################################################################################################


// Déclaration de l'interface 'PokemonImageLocalDataSource' avec les fonctions nécessaires.
abstract class PokemonImageLocalDataSource {
  // Fonction pour mettre en cache l'image d'un Pokémon.
  Future<void> cachePokemonImage(
      {required PokemonImageModel? pokemonImageToCache});
  // Fonction pour obtenir la dernière image d'un Pokémon mise en cache.
  Future<PokemonImageModel> getLastPokemonImage();
}

// ############################################################################################################


// Définition d'une constante pour la clé utilisée pour le stockage local.
const cachedPokemonImage = 'CACHED_POKEMON_IMAGE';

// Implémentation concrète de l'interface 'PokemonImageLocalDataSource'.
class PokemonImageLocalDataSourceImpl implements PokemonImageLocalDataSource {
  // Déclaration et initialisation de 'sharedPreferences' pour l'accès aux fonctions de stockage local.
  final SharedPreferences sharedPreferences;

  // Constructeur de 'PokemonImageLocalDataSourceImpl' avec 'sharedPreferences' requis.
  PokemonImageLocalDataSourceImpl({required this.sharedPreferences});

  // Implémentation de la fonction pour obtenir la dernière image d'un Pokémon mise en cache.
  @override
  Future<PokemonImageModel> getLastPokemonImage() {
    // Récupération de la chaîne JSON mise en cache.
    final jsonString = sharedPreferences.getString(cachedPokemonImage);
    // Si la chaîne JSON est non nulle, retourner l'image décodée.
    if (jsonString != null) {
      return Future.value(
          PokemonImageModel.fromJson(json: json.decode(jsonString)));
    } else {
      // Si la chaîne JSON est nulle, lever une exception de type 'CacheException'.
      throw CacheException();
    }
  }

  // Implémentation de la fonction pour mettre en cache l'image d'un Pokémon.
  @override
  Future<void> cachePokemonImage(
      {required PokemonImageModel? pokemonImageToCache}) async {
    // Vérification que l'image du Pokémon n'est pas nulle.
    if (pokemonImageToCache != null) {
      // Mise en cache de l'image du Pokémon en encodant l'objet en chaîne JSON.
      sharedPreferences.setString(
        cachedPokemonImage,
        json.encode(
          pokemonImageToCache.toJson(),
        ),
      );
    } else {
      // Si l'image du Pokémon est nulle, lever une exception de type 'CacheException'.
      throw CacheException();
    }
  }
}
