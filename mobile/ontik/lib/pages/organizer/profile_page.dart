import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  final _nomCtrl = TextEditingController();
  final _prenomsCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  bool _saving = false;
  final _userService = UserService();

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
    final code = userCode ?? '';
    if (code.isEmpty) return;

    setState(() => _loading = true);
    try {
      final data = await _userService.getOrganizerProfile(code);
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
    final code = userCode ?? '';

    setState(() => _saving = true);
    try {
      await _userService.updateOrganizerProfile(code, {
        'nom': _nomCtrl.text,
        'prenoms': _prenomsCtrl.text,
        'email': _emailCtrl.text,
        'tel': _telCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour'), backgroundColor: AppTheme.secondaryColor));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.errorColor));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logout() {
    clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const _LoginRedirect()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _emailCtrl.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
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
                  leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text('Déconnexion', style: TextStyle(color: AppTheme.errorColor)),
                  onTap: _logout,
                ),
              ],
            ),
    );
  }
}

class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Redirection vers la connexion...')),
    );
  }
}
