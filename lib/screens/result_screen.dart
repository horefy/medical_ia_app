import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/consultation.dart';

class ResultScreen extends StatelessWidget {
  final Consultation consultation;

  const ResultScreen({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    Color levelColor = Colors.green;
    IconData levelIcon = Icons.check_circle_outline_rounded;
    String statusTitle = "Observation recommandée";
    
    if (consultation.level == 'MEDIUM') {
      levelColor = Colors.orange;
      levelIcon = Icons.info_outline_rounded;
      statusTitle = "Conseils médicaux";
    } else if (consultation.level == 'HIGH') {
      levelColor = Colors.red;
      levelIcon = Icons.warning_amber_rounded;
      statusTitle = "Urgence médicale";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyse terminée'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(levelIcon, size: 80, color: levelColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    statusTitle,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: levelColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    consultation.imageLabel ?? "Analyse des symptômes",
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Color(0xFF007BFF)),
                      SizedBox(width: 8),
                      Text(
                        "Rapport Médical Expert",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: MarkdownBody(
                      data: consultation.recommendation,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF007BFF), height: 2.0),
                        blockquote: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tableBorder: TableBorder.all(color: Colors.grey.shade300, width: 1),
                        tableBody: const TextStyle(fontSize: 13),
                        tableHead: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildDisclaimer(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour à l\'accueil'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip_outlined, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "AVERTISSEMENT : Ce rapport est généré par une intelligence artificielle à des fins de démonstration académique. Il ne constitue pas un avis médical officiel. En cas de doute, consultez immédiatement un médecin.",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
