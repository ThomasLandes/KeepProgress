class User {
  final String nom;
  final int age;
  final String email;

  User({required this.nom, required this.age, required this.email});

  // Convertir depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(nom: json['nom'], age: json['age'], email: json['email']);
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {'nom': nom, 'age': age, 'email': email};
  }
}
