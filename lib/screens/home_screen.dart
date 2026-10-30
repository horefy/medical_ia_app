import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/symptom_provider.dart';
import 'symptom_form_screen.dart';
import '../models/consultation.dart';
import 'result_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(consultationHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainCard(context),
                  const SizedBox(height: 30),
                  const Text(
                    'Historique récent',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          historyAsync.when(
            data: (history) => history.isEmpty
                ? const SliverFillRemaining(child: Center(child: Text('Aucun scan effectué.')))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildHistoryCard(context, history[index]),
                      childCount: history.length > 3 ? 3 : history.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Erreur: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF007BFF),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Santé Connect'),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Color(0xFF00B4D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.psychology, color: Color(0xFF007BFF), size: 35)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Analyse Intelligente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Bilan instantané par IA', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomFormScreen())),
              icon: const Icon(Icons.add_task),
              label: const Text('DÉMARRER LE BILAN'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Consultation consult) {
    final bool isHigh = consult.level == 'HIGH';
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(isHigh ? Icons.warning_rounded : Icons.check_circle, color: isHigh ? Colors.red : Colors.green),
        title: Text(consult.imageLabel ?? 'Analyse Symptômes', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Le ${consult.date.day}/${consult.date.month}'),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(consultation: consult))),
      ),
    );
  }
}
