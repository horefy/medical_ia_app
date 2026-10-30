import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/symptom_provider.dart';
import '../models/consultation.dart';
import 'result_screen.dart';
import 'camera_screen.dart';

class SymptomFormScreen extends ConsumerWidget {
  const SymptomFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomsAsync = ref.watch(symptomsListProvider);
    final selectedIds = ref.watch(selectedSymptomsProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vos symptômes'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Quels sont les signes que vous ressentez ?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: symptomsAsync.when(
              data: (symptoms) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = symptoms[index];
                  final isSelected = selectedIds.contains(symptom.id);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        if (!isSelected) {
                          ref.read(selectedSymptomsProvider.notifier).state = [...selectedIds, symptom.id];
                        } else {
                          ref.read(selectedSymptomsProvider.notifier).state = selectedIds.where((id) => id != symptom.id).toList();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF007BFF).withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007BFF) : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    symptom.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFF007BFF) : Colors.black,
                                    ),
                                  ),
                                  if (symptom.description.isNotEmpty)
                                    Text(
                                      symptom.description,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF007BFF))
                            else
                              const Icon(Icons.add_circle_outline, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraScreen()),
                        );
                        if (result != null && context.mounted) {
                          ref.read(selectedImageProvider.notifier).state = File(result['file_path']);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Caméra'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          ref.read(selectedImageProvider.notifier).state = File(image.path);
                        }
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galerie'),
                    ),
                  ),
                ],
              ),
              if (selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 5),
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(selectedImage),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => ref.read(selectedImageProvider.notifier).state = null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Image prête pour l'analyse",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedIds.isEmpty && selectedImage == null) 
                    ? null 
                    : () async {
                        final consultation = await ref.read(medicalServiceProvider).submitConsultation(
                          symptomIds: selectedIds,
                          imageFile: selectedImage,
                        );
                        
                        if (context.mounted) {
                          if (consultation != null) {
                            ref.invalidate(consultationHistoryProvider);
                            ref.read(selectedImageProvider.notifier).state = null;
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => ResultScreen(consultation: consultation))
                            );
                          } else {
                            // Message d'erreur clair si le serveur est éteint
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Erreur : Le serveur Django est éteint ou injoignable. Relancez 'python manage.py runserver'."),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                  child: const Text('Analyser ma situation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
