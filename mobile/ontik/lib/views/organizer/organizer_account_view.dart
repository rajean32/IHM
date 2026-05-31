import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../models/dashboard.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../models/api_wrapper.dart';

class OrganizerAccountView extends ConsumerStatefulWidget {
  const OrganizerAccountView({super.key});

  @override
  ConsumerState<OrganizerAccountView> createState() => _OrganizerAccountViewState();
}

class _OrganizerAccountViewState extends ConsumerState<OrganizerAccountView> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  final _nomCtrl = TextEditingController();
  final _prenomsCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() { super.initState(); _loadProfile(); }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomsCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final authState = ref.read(authControllerProvider);
    final code = authState.user?.codeUtilisateur ?? '';
    if (code.isEmpty) return;

    setState(() => _loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/organisateurs/$code');
      final data = ApiWrapper.fromJson(resp).getData((d) => d);
      if (!mounted) return;
      setState(() {
        _profile = data;
        _nomCtrl.text = data['nom'] ?? '';
        _prenomsCtrl.text = data['prenoms'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _telCtrl.text = data['tel'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final authState = ref.read(authControllerProvider);
    final code = authState.user?.codeUtilisateur ?? '';

    setState(() => _saving = true);
    try {
      final client = ApiClient();
      await client.put('/organisateurs/$code', data: {
        'nom': _nomCtrl.text,
        'prenoms': _prenomsCtrl.text,
        'email': _emailCtrl.text,
        'tel': _telCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    child: Text(
                      (_nomCtrl.text.isNotEmpty ? _nomCtrl.text[0] : '?').toUpperCase(),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_prenomsCtrl.text} ${_nomCtrl.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  authState.user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prenomsCtrl,
                  decoration: const InputDecoration(labelText: 'Prénoms', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Enregistrer'),
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  onTap: () => ref.read(authControllerProvider.notifier).logout(),
                ),
              ],
            ),
    );
  }
}
