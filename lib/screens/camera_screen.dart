import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import '../services/ai_service.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await ref.read(camerasProvider.future);
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune caméra détectée.")),
        );
      }
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max, // Augmentation de la résolution pour la fiabilité de l'IA
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      // Verrouillage du focus pour la macro (utile en médical)
      if (_controller!.value.isInitialized) {
        await _controller!.setFocusMode(FocusMode.auto);
      }
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      // 1. Capture de la photo
      final XFile file = await _controller!.takePicture();
      
      // 2. Vérification que le fichier existe et est prêt
      final File imageFile = File(file.path);
      if (!await imageFile.exists()) throw Exception("Fichier image non trouvé.");

      // 3. Passage à l'analyse (On retourne le chemin pour traitement par le backend)
      final result = await _aiService.predict(imageFile);
      
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      debugPrint("Take Picture Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de capture : ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan Médical IA'),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Preview Camera
          if (_isInitialized)
            Center(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF))),
          
          // Guide de Scan (Mission principale)
          _buildScanOverlay(),

          // Bouton de capture
          _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: _isTakingPicture ? Colors.green : Colors.white, width: 2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  // Coins stylisés
                  for (var i = 0; i < 4; i++)
                    Positioned(
                      top: (i < 2) ? 0 : null,
                      bottom: (i >= 2) ? 0 : null,
                      left: (i % 2 == 0) ? 0 : null,
                      right: (i % 2 != 0) ? 0 : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: (i < 2) ? const BorderSide(color: Color(0xFF00B4D8), width: 6) : BorderSide.none,
                            bottom: (i >= 2) ? const BorderSide(color: Color(0xFF00B4D8), width: 6) : BorderSide.none,
                            left: (i % 2 == 0) ? const BorderSide(color: Color(0xFF00B4D8), width: 6) : BorderSide.none,
                            right: (i % 2 != 0) ? const BorderSide(color: Color(0xFF00B4D8), width: 6) : BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Placez le signe au centre du cadre',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _takePictureAndAnalyze,
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTakingPicture ? Colors.grey : Colors.white,
              ),
              child: _isTakingPicture 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                : const Icon(Icons.camera_alt, size: 40, color: Color(0xFF007BFF)),
            ),
          ),
        ),
      ),
    );
  }
}
