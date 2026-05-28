import 'package:dio/dio.dart';

import '../../models/actualite_model.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class ActualiteService {

  final Dio dio = Dio();

  // =========================
  // GET ACTUALITES
  // =========================

  Future<List<ActualiteModel>> getActualites() async {

    try {

      final token =
          await AuthService().getAccessToken();

      final response = await dio.get(

        '${ApiConstants.baseUrl}/actualites/',

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return (response.data as List)

          .map(
            (e) => ActualiteModel.fromJson(e),
          )

          .toList();

    } catch (e) {

      print('Erreur getActualites: $e');

      return [];
    }
  }

  // =========================
  // PUBLIER ACTUALITE
  // =========================

  /// [fichiers] = liste de XFile (image_picker)
  /// Compatible Flutter Web ET mobile
  Future<bool> publierActualite({

    required String titre,
    required String corps,
    required List<MediaUpload> fichiers,

  }) async {

    try {

      final token =
          await AuthService().getAccessToken();

      // FORM DATA
      FormData formData = FormData.fromMap({

        'titre': titre,
        'corps': corps,

      });

      // ADD FILES via bytes (compatible Web + Mobile)
      for (final media in fichiers) {

        formData.files.add(

          MapEntry(

            'medias',

            MultipartFile.fromBytes(
              media.bytes,
              filename: media.filename,
            ),
          ),
        );
      }

      // POST REQUEST
      final response = await dio.post(

        '${ApiConstants.baseUrl}/actualites/',

        data: formData,

        options: Options(

          headers: {

            'Authorization':
                'Bearer $token',

            'Content-Type':
                'multipart/form-data',
          },
        ),
      );

      // SUCCESS
      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        return true;
      }

      return false;

    } on DioException catch (e) {

      print(
        'Dio Error publierActualite: '
        '${e.response?.data}',
      );

      return false;

    } catch (e) {

      print(
        'Erreur publierActualite: $e',
      );

      return false;
    }
  }

  // =========================
  // MODIFIER ACTUALITE
  // =========================

  Future<bool> modifierActualite({

    required int id,
    required String titre,
    required String corps,
    required List<MediaUpload> fichiers,

  }) async {

    try {

      final token =
          await AuthService().getAccessToken();

      // FORM DATA
      FormData formData = FormData.fromMap({

        'titre': titre,
        'corps': corps,

      });

      // ADD FILES via bytes (compatible Web + Mobile)
      for (final media in fichiers) {

        formData.files.add(

          MapEntry(

            'medias',

            MultipartFile.fromBytes(
              media.bytes,
              filename: media.filename,
            ),
          ),
        );
      }

      // PUT REQUEST
      final response = await dio.put(

        '${ApiConstants.baseUrl}/actualites/$id/',

        data: formData,

        options: Options(

          headers: {

            'Authorization':
                'Bearer $token',

            'Content-Type':
                'multipart/form-data',
          },
        ),
      );

      // SUCCESS
      if (response.statusCode == 200) {

        return true;
      }

      return false;

    } on DioException catch (e) {

      print(
        'Dio Error modifierActualite: '
        '${e.response?.data}',
      );

      return false;

    } catch (e) {

      print(
        'Erreur modifierActualite: $e',
      );

      return false;
    }
  }

  // =========================
  // SUPPRIMER ACTUALITE
  // =========================

  Future<bool> supprimerActualite({

    required int id,

  }) async {

    try {

      final token =
          await AuthService().getAccessToken();

      final response = await dio.delete(

        '${ApiConstants.baseUrl}/actualites/$id/',

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {

        return true;
      }

      return false;

    } on DioException catch (e) {

      print(
        'Dio Error supprimerActualite: '
        '${e.response?.data}',
      );

      return false;

    } catch (e) {

      print(
        'Erreur supprimerActualite: $e',
      );

      return false;
    }
  }
}

// =========================
// MODÈLE MEDIA UPLOAD
// Compatible Web + Mobile
// =========================

class MediaUpload {

  final List<int> bytes;
  final String filename;
  final bool isVideo;

  const MediaUpload({
    required this.bytes,
    required this.filename,
    required this.isVideo,
  });

  /// Crée un MediaUpload depuis un XFile (image_picker)
  static Future<MediaUpload> fromXFile(
    dynamic xfile, {
    required bool isVideo,
  }) async {
    final bytes = await xfile.readAsBytes();
    return MediaUpload(
      bytes: bytes,
      filename: xfile.name,
      isVideo: isVideo,
    );
  }
}