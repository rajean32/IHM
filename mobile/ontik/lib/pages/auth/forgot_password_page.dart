import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/routes/client_routes.dart';
import '../../core/routes/organizer_routes.dart';
import '../../core/routes/admin_routes.dart';
import '../../core/utils/error_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _newEmailCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (userCode != null) _codeCtrl.text = userCode!;
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _newEmailCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().firstLogin(_codeCtrl.text.trim(), _newEmailCtrl.text.trim(), _newPasswordCtrl.text);
      if (!mounted) return;
      final role = userRole;
      if (role == 'ADMINISTRATEUR') {
        Navigator.pushReplacementNamed(context, AdminRoutes.layout);
      } else if (role == 'ORGANISATEUR') {
        Navigator.pushReplacementNamed(context, OrganizerRoutes.layout);
      } else {
        Navigator.pushReplacementNamed(context, ClientRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorString(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Back / Logout button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.fieldFill,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'First-Time Setup',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Update your credentials to secure your account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 2,
      color: AppColors.card,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Security Update',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your account requires a new email and password',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // User Code (readonly)
              _buildTextField(
                controller: _codeCtrl,
                label: 'User Code',
                hint: 'Your code',
                icon: Icons.badge_outlined,
                readOnly: true,
                validator: null,
              ),
              const SizedBox(height: 16),

              // New Email
              _buildTextField(
                controller: _newEmailCtrl,
                label: 'New Email',
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your new email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              _buildPasswordField(
                controller: _newPasswordCtrl,
                label: 'New Password',
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter new password';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm Password',
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v != _newPasswordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null) _buildErrorBanner(),
              if (_error != null) const SizedBox(height: 16),

              // Submit
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? AppColors.textMuted : AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: readOnly ? AppColors.surface : AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Min. 6 characters',
        prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Update & Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
      label: Text(
        'Logout',
        style: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}