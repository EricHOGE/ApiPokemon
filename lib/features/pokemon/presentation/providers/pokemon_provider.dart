import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../core/params/params.dart';
import '../../../pokemon_image/presentation/providers/pokemon_image_provider.dart';
import '../../business/entities/pokemon_entity.dart';
import '../../business/usecases/get_pokemon.dart';
import '../../data/datasources/pokemon_local_data_source.dart';
import '../../data/datasources/pokemon_remote_data_source.dart';
import '../../data/repositories/pokemon_repository_impl.dart';

class PokemonProvider extends ChangeNotifier {
  PokemonEntity? pokemon;
  Failure? failure;

  PokemonProvider({
    this.pokemon,
    this.failure,
  });

  void eitherFailureOrPokemon({
    required String value,
    required PokemonImageProvider pokemonImageProvider,
  }) async {
    print('eitherFailureOrPokemon started with value: $value');
    PokemonRepositoryImpl repository = PokemonRepositoryImpl(
      remoteDataSource: PokemonRemoteDataSourceImpl(dio: Dio()),
      localDataSource: PokemonLocalDataSourceImpl(
          sharedPreferences: await SharedPreferences.getInstance()),
      networkInfo: NetworkInfoImpl(DataConnectionChecker()),
    );

    final failureOrPokemon = await GetPokemon(repository).call(
      params: PokemonParams(id: value),
    );

    failureOrPokemon.fold(
      (newFailure) {
        print('Failed to get pokemon with error: ${newFailure.errorMessage}');
        pokemon = null;
        failure = newFailure;
        notifyListeners();
      },
      (newPokemon) {
        print('Pokemon retrieved successfully: ${newPokemon.name}');
        pokemon = newPokemon;
        failure = null;
        pokemonImageProvider.eitherFailureOrPokemonImage(
            pokemonEntity: newPokemon);
        notifyListeners();
      },
    );
  }
}
