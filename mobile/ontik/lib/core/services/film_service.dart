import '../api/dio_config.dart';
import '../api/endpoints.dart';
import '../../models/film_model.dart';

class FilmService {
  Future<List<Film>> getAllFilms() async {
    final response = await dio.get('${Endpoints.base}/films');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Film.fromJson(e)).toList();
  }

  Future<List<Film>> getFilmsAVenir() async {
    final response = await dio.get('${Endpoints.base}/films/a-venir');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Film.fromJson(e)).toList();
  }

  Future<Film> getFilmById(int id) async {
    final response = await dio.get('${Endpoints.base}/films/$id');
    return Film.fromJson(response.data['data']);
  }

  Future<Film> getFilmByEvenement(int idEvenement) async {
    final response = await dio.get('${Endpoints.base}/films/evenement/$idEvenement');
    return Film.fromJson(response.data['data']);
  }

  Future<Film> createFilm(Film film) async {
    final response = await dio.post(
      '${Endpoints.base}/films',
      data: film.toJson(),
    );
    return Film.fromJson(response.data['data']);
  }

  Future<Film> updateFilm(int id, Film film) async {
    final response = await dio.put(
      '${Endpoints.base}/films/$id',
      data: film.toJson(),
    );
    return Film.fromJson(response.data['data']);
  }

  Future<void> deleteFilm(int id) async {
    await dio.delete('${Endpoints.base}/films/$id');
  }

  Future<List<SeanceCinema>> getSeancesByFilm(int idFilm) async {
    final response = await dio.get('${Endpoints.base}/films/$idFilm/seances');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => SeanceCinema.fromJson(e)).toList();
  }

  Future<SeanceCinema> addSeance(int idFilm, SeanceCinema seance) async {
    final response = await dio.post(
      '${Endpoints.base}/films/$idFilm/seances',
      data: {
        'dateSeance': seance.dateSeance.toIso8601String().split('T').first,
        'heureSeance': seance.heureSeance,
        'version': seance.version,
        'langue': seance.langue,
        'sousTitres': seance.sousTitres,
      },
    );
    return SeanceCinema.fromJson(response.data['data']);
  }
}