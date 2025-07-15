class Session {
  final String id;
  final String titre;
  final DateTime date;

  Session({required this.id, required this.titre, required this.date});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(id: json['id'], titre: json['titre'], date: DateTime.parse(json['date']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'titre': titre, 'date': date.toIso8601String()};
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(id: map['id'], titre: map['titre'], date: DateTime.parse(map['date']));
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'titre': titre, 'date': date.toIso8601String()};
  }
}
