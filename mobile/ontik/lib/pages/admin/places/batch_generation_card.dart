import 'package:flutter/material.dart';
import 'package:ontik/core/assets/app_colors.dart';

class BatchGenerationCard extends StatefulWidget {
  final void Function(String rang, int debut, int fin) onGenerate;
  const BatchGenerationCard({super.key, required this.onGenerate});

  @override
  State<BatchGenerationCard> createState() => _BatchGenerationCardState();
}

class _BatchGenerationCardState extends State<BatchGenerationCard> {
  final _rangCtrl = TextEditingController();
  final _debutCtrl = TextEditingController();
  final _finCtrl = TextEditingController();

  @override
  void dispose() {
    _rangCtrl.dispose();
    _debutCtrl.dispose();
    _finCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    final rang = _rangCtrl.text.trim();
    final debut = int.tryParse(_debutCtrl.text);
    final fin = int.tryParse(_finCtrl.text);
    if (rang.isEmpty || debut == null || fin == null) return;
    if (fin < debut) return;
    widget.onGenerate(rang, debut, fin);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Génération en masse', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rangCtrl,
              decoration: const InputDecoration(
                labelText: 'Rang',
                hintText: 'B',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _debutCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'N° début',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 18, color: AppColors.textMuted),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _finCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'N° fin',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Générer'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
