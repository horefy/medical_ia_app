class Symptom {
  final int id;
  final String name;
  final String description;

  Symptom({required this.id, required this.name, required this.description});

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}
