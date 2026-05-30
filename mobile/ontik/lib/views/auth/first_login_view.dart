import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/loading_overlay.dart';

class FirstLoginView extends ConsumerStatefulWidget {
  const FirstLoginView({super.key});

  @override
  ConsumerState<FirstLoginView> createState() => _FirstLoginViewState();
}

class _FirstLoginViewState extends ConsumerState<FirstLoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl = TextEditingController();
  late final TextEditingController _newPasswordCtrl = TextEditingController();
  late final TextEditingController _confirmPasswordCtrl = TextEditingController();
  late final TextEditingController _newEmailCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        _codeCtrl.text = user.codeUtilisateur;
        if (user.email.isNotEmpty) {
          _newEmailCtrl.text = user.email;
        }
      }
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _newEmailCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).firstLoginUpdate(
        codeUtilisateur: _codeCtrl.text.trim(),
        newPassword: _newPasswordCtrl.text,
        newEmail: _newEmailCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (!next.needsFirstLogin && next.isAuthenticated) {
        final role = next.user?.role;
        if (role == 'ADMINISTRATEUR') {
          context.go('/admin');
        } else if (role == 'ORGANISATEUR') {
          context.go('/organizer');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 80, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text(
                      'First-Time Setup',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please update your password and email address to continue.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'User Code',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your user code' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'New Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your new email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v != _newPasswordCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update & Continue', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).logout();
                        context.go('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
