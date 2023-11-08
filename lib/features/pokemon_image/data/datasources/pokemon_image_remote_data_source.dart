// Importation de la bibliothèque IO de Dart pour accéder aux chemins du système de fichiers.
import 'dart:io';

// Dio est un client HTTP puissant pour Dart, prenant en charge les intercepteurs,
// la configuration globale, les données de formulaire, l'annulation de la demande,
// le téléchargement de fichiers, les délais d'attente, etc.
import 'package:dio/dio.dart';
// Fournisseur de chemin pour trouver les emplacements couramment utilisés sur le système de fichiers.
import 'package:path_provider/path_provider.dart';

// Gestion des exceptions personnalisées pour l'application.
import '../../../../../core/errors/exceptions.dart';
// Classe de paramètres pour le passage de données dans les cas d'utilisation.
import '../../../../../core/params/params.dart';
// Le modèle de données représentant une image de Pokémon.
import '../../../../core/constants/constants.dart';
import '../models/pokemon_image_model.dart';

// Une classe abstraite définissant le contrat pour récupérer les images de Pokémon à distance.
abstract class PokemonImageRemoteDataSource {
  Future<PokemonImageModel> getPokemonImage(
      {required PokemonImageParams pokemonImageParams});
}

// Une implémentation concrète de PokemonImageRemoteDataSource.
class PokemonImageRemoteDataSourceImpl implements PokemonImageRemoteDataSource {
  // Client Dio pour effectuer des requêtes HTTP.
  final Dio dio;

  // Constructeur exigeant une instance Dio non nulle.
  PokemonImageRemoteDataSourceImpl({required this.dio});

  // Implémentation du contrat pour récupérer une image de Pokémon via une requête HTTP.
  @override
  Future<PokemonImageModel> getPokemonImage(
      {required PokemonImageParams pokemonImageParams}) async {
    // Récupération du répertoire où sont stockés les documents de l'application.
    Directory directory = await getApplicationDocumentsDirectory();

    // Suppression des données existantes dans le répertoire pour économiser de l'espace
    // et éviter l'encombrement. (Cette approche pourrait être agressive selon le cas d'utilisation - à revoir.)
    // Vérifiez si le répertoire existe avant de tenter de le supprimer.
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    // Construction du chemin de fichier où l'image téléchargée sera stockée.
    final String pathFile = '${directory.path}/${pokemonImageParams.name}.png';

    // Utilisation de Dio pour télécharger l'image depuis l'URL fournie vers le chemin de fichier.
    final response = await dio.download(
      pokemonImageParams.imageUrl,
      pathFile,
    );

    // Vérification si la réponse du serveur est réussie.
    if (response.statusCode == 200) {
      // Si le téléchargement a réussi, création d'un nouveau modèle PokemonImageModel à partir du JSON.
      // Cela suppose que 'kPath' est une constante pour la clé utilisée dans la représentation JSON du modèle.
      return PokemonImageModel.fromJson(json: {kPath: pathFile});
    } else {
      // Si le téléchargement échoue ou que la réponse du serveur n'est pas 200, une exception de serveur est levée.
      throw ServerException();
    }
  }
}
