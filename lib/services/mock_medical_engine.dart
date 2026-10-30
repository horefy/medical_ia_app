import '../models/symptom.dart';

class MockMedicalEngine {
  /// Fournit uniquement une liste de symptômes de base si le serveur est injoignable.
  /// Toute la logique de prédiction a été supprimée pour utiliser l'IA réelle.
  static List<Symptom> getMockSymptoms() {
    return [
      Symptom(id: 1, name: "Fièvre", description: "Température > 38°C"),
      Symptom(id: 2, name: "Toux", description: "Toux sèche ou grasse"),
      Symptom(id: 3, name: "Fatigue", description: "Sensation d'épuisement"),
      Symptom(id: 4, name: "Difficulté respiratoire", description: "Essoufflement"),
      Symptom(id: 5, name: "Démangeaisons", description: "Irritation cutanée"),
    ];
  }
}
