class Consultation {
  final int id;
  final DateTime date;
  final List<String> symptomsNames;
  final String recommendation;
  final String level;
  final String? imageLabel;
  final double? imageConfidence;

  Consultation({
    required this.id,
    required this.date,
    required this.symptomsNames,
    required this.recommendation,
    required this.level,
    this.imageLabel,
    this.imageConfidence,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'],
      date: DateTime.parse(json['date']),
      symptomsNames: List<String>.from(json['symptoms_names']),
      recommendation: json['result_recommendation'],
      level: json['result_level'],
      imageLabel: json['image_analysis_label'],
      imageConfidence: json['image_analysis_confidence'],
    );
  }
}
