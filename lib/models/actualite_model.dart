class MediaModel {

  final String fichier;
  final bool isVideo;

  MediaModel({
    required this.fichier,
    required this.isVideo,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {

    return MediaModel(
      fichier: json['fichier'],
      isVideo: json['is_video'],
    );
  }
}


class ActualiteModel {

  final int id;

  final String titre;

  final String corps;

  final String createdAt;

  final List<MediaModel> medias;

  ActualiteModel({
    required this.id,
    required this.titre,
    required this.corps,
    required this.createdAt,
    required this.medias,
  });

  factory ActualiteModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ActualiteModel(
      id: json['id'],
      titre: json['titre'],
      corps: json['corps'],
      createdAt: json['created_at'],

      medias: (json['medias'] as List)
          .map((e) => MediaModel.fromJson(e))
          .toList(),
    );
  }
}