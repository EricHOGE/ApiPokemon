// Importation des packages nécessaires pour la vérification de la connexion réseau,
// l'envoi de requêtes HTTP, les widgets Flutter et la persistance des données localement.
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importation des modules internes de l'application, y compris la logique de connexion réseau,
// la gestion des erreurs, les paramètres pour les use cases, et les entités métier.
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../../../core/constants/constants.dart';
import '../../../pokemon/business/entities/pokemon_entity.dart';
import '../../business/entities/pokemon_image_entity.dart';
import '../../business/usecases/get_pokemon_image.dart';
import '../../data/datasources/pokemon_image_local_data_source.dart';
import '../../data/datasources/pokemon_image_remote_data_source.dart';
import '../../data/repositories/pokemon_image_repository_impl.dart';

// Déclaration de la classe PokemonImageProvider qui étend ChangeNotifier, ce qui permet
// à ce provider d'informer les widgets qui écoutent de tout changement d'état.
class PokemonImageProvider extends ChangeNotifier {
  // Déclaration des propriétés qui peuvent être nulles pour stocker l'image du Pokémon et
  // toute erreur qui pourrait survenir pendant la récupération de l'image.
  PokemonImageEntity? pokemonImage;
  Failure? failure;

  // Constructeur du Provider permettant l'initialisation optionnelle de ses propriétés.
  PokemonImageProvider({
    this.pokemonImage,
    this.failure,
  });

  // Méthode asynchrone qui tente de récupérer une image de Pokémon en utilisant un cas d'utilisation spécifique.
  // Si une erreur survient, elle est capturée et gérée.
  void eitherFailureOrPokemonImage(
      {required PokemonEntity pokemonEntity}) async {
    print(
        'Début de eitherFailureOrPokemonImage pour le Pokémon : ${pokemonEntity.name}');

    // Création de l'implémentation du dépôt en injectant les dépendances nécessaires
    // pour les sources de données locales et distantes, ainsi que pour l'info de connexion réseau.
    PokemonImageRepositoryImpl repository = PokemonImageRepositoryImpl(
      remoteDataSource: PokemonImageRemoteDataSourceImpl(
        dio: Dio(),
      ),
      localDataSource: PokemonImageLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    String imageUrl = isShiny
        ? pokemonEntity.sprites.other.officialArtwork.frontShiny
        : pokemonEntity.sprites.other.officialArtwork.frontDefault;

    print('URL de l\'image à récupérer : $imageUrl');
    print('Appel de GetPokemonImage avec imageUrl : $imageUrl');
    // Appel du cas d'utilisation GetPokemonImage et attente de la réponse.
    final failureOrPokemonImage =
        await GetPokemonImage(pokemonImageRepository: repository).call(
      pokemonImageParams:
          PokemonImageParams(name: pokemonEntity.name, imageUrl: imageUrl),
    );

    // Utilisation de la méthode fold pour traiter les deux cas possibles de la réponse : échec ou succès.
    // En cas d'échec, la propriété 'failure' est mise à jour et 'pokemonImage' est réinitialisée à nulle.
    // En cas de succès, la propriété 'pokemonImage' est mise à jour avec la nouvelle image.
    failureOrPokemonImage.fold(
      (Failure newFailure) {
        print(
            'Échec de la récupération de l\'image du Pokémon avec l\'erreur : ${newFailure.errorMessage}');
        pokemonImage = null; // Réinitialisation de l'image en cas d'échec.
        failure = newFailure; // Mise à jour de l'erreur.
        notifyListeners(); // Notification des widgets écoutant ce provider.
      },
      (PokemonImageEntity newPokemonImage) {
        print(
            'Image du Pokémon récupérée avec succès : ${newPokemonImage.path}');
        pokemonImage =
            newPokemonImage; // Mise à jour avec la nouvelle image du Pokémon.
        failure =
            null; // Aucune erreur, donc réinitialisation de la propriété 'failure'.
        notifyListeners(); // Notification des widgets écoutant ce provider pour reconstruire leurs vues.
      },
    );
  }
}
