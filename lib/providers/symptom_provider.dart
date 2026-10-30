import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/symptom.dart';
import '../services/medical_service.dart';

final medicalServiceProvider = Provider((ref) => MedicalService());

final symptomsListProvider = FutureProvider<List<Symptom>>((ref) async {
  return ref.watch(medicalServiceProvider).getSymptoms();
});

final selectedSymptomsProvider = StateProvider<List<int>>((ref) => []);

final selectedImageProvider = StateProvider<File?>((ref) => null);

final consultationHistoryProvider = FutureProvider((ref) async {
  return ref.watch(medicalServiceProvider).getHistory();
});
