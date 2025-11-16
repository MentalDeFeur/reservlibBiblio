class Livre {
  final int? id;
  final String titre;
  final String auteur;
  final String thematique;
  final String numero;
  final String? description;
  final String? coverUrl;
  final DateTime dateAjout;

  Livre({
    this.id,
    required this.titre,
    required this.auteur,
    required this.thematique,
    required this.numero,
    this.description,
    this.coverUrl,
    DateTime? dateAjout,
  }) : dateAjout = dateAjout ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'thematique': thematique,
      'numero': numero,
      'description': description,
      'coverUrl': coverUrl,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }

  factory Livre.fromMap(Map<String, dynamic> map) {
    return Livre(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      auteur: map['auteur'] as String,
      thematique: map['thematique'] as String,
      numero: map['numero'] as String,
      description: map['description'] as String?,
      coverUrl: map['coverUrl'] as String?,
      dateAjout: DateTime.parse(map['dateAjout'] as String),
    );
  }

  Livre copyWith({
    int? id,
    String? titre,
    String? auteur,
    String? thematique,
    String? numero,
    String? description,
    String? coverUrl,
    DateTime? dateAjout,
  }) {
    return Livre(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      thematique: thematique ?? this.thematique,
      numero: numero ?? this.numero,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }
}
