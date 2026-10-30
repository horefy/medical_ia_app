import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/symptom.dart';
import '../models/consultation.dart';
import 'mock_medical_engine.dart';

class MedicalService {
  final ApiClient _apiClient = ApiClient();
  static const String _historyKey = 'local_consultation_history';

  Future<List<Symptom>> getSymptoms() async {
    try {
      final response = await _apiClient.dio.get('/symptoms/');
      return (response.data as List).map((s) => Symptom.fromJson(s)).toList();
    } catch (e) {
      return MockMedicalEngine.getMockSymptoms();
    }
  }

  Future<Consultation?> submitConsultation({
    required List<int> symptomIds,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'symptoms': symptomIds.join(','),
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: 'analysis.jpg'),
        ));
      }

      // APPEL STRICT AU BACKEND (IA GROQ)
      final response = await _apiClient.dio.post('/consult/', data: formData);
      final result = Consultation.fromJson(response.data);
      
      // Sauvegarde systématique dans l'historique local après succès
      await _saveToLocalHistory(result);
      return result;
      
    } catch (e) {
      print("ERREUR IA RÉELLE : $e");
      // On ne retourne plus de simulation, mais l'erreur pour informer l'utilisateur
      return null;
    }
  }

  Future<void> _saveToLocalHistory(Consultation consult) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    List<dynamic> history = historyJson != null ? jsonDecode(historyJson) : [];
    
    history.insert(0, {
      'id': consult.id,
      'date': consult.date.toIso8601String(),
      'symptoms_names': consult.symptomsNames,
      'result_recommendation': consult.recommendation,
      'result_level': consult.level,
      'image_analysis_label': consult.imageLabel,
      'image_analysis_confidence': consult.imageConfidence,
    });
    
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<Consultation>> getHistory() async {
    try {
      final response = await _apiClient.dio.get('/history/');
      return (response.data as List).map((c) => Consultation.fromJson(c)).toList();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      if (historyJson == null) return [];
      
      final List<dynamic> history = jsonDecode(historyJson);
      return history.map((c) => Consultation.fromJson(c)).toList();
    }
  }
}
