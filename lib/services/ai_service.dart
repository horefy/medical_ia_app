import 'dart:io';

class AIService {
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> loadModel() async {
    // Désactivé temporairement (passage en backend IA)
    _isAvailable = false;
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    // Simule une préparation de fichier pour le backend
    return {
      'label': 'Image prête pour analyse',
      'confidence': 0.0,
      'file_path': imageFile.path
    };
  }
}
