class Reservation {
  final int? id;
  final String titre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? nomReservant;
  final String? description;
  final String? categorie;

  Reservation({
    this.id,
    required this.titre,
    required this.dateDebut,
    required this.dateFin,
    this.nomReservant,
    this.description,
    this.categorie,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'nomReservant': nomReservant,
      'description': description,
      'categorie': categorie,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      dateDebut: DateTime.parse(map['dateDebut'] as String),
      dateFin: DateTime.parse(map['dateFin'] as String),
      nomReservant: map['nomReservant'] as String?,
      description: map['description'] as String?,
      categorie: map['categorie'] as String?,
    );
  }

  Reservation copyWith({
    int? id,
    String? titre,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? nomReservant,
    String? description,
    String? categorie,
  }) {
    return Reservation(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      nomReservant: nomReservant ?? this.nomReservant,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
    );
  }

  bool conflitsAvec(Reservation autre) {
    return (dateDebut.isBefore(autre.dateFin) &&
        dateFin.isAfter(autre.dateDebut));
  }
}
