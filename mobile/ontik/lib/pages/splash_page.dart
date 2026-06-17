import 'package:flutter/material.dart';
import '../core/api/dio_config.dart';
import '../core/assets/app_colors.dart';
import '../core/routes/client_routes.dart';
import '../core/routes/organizer_routes.dart';
import '../core/routes/admin_routes.dart';
import '../core/routes/auth_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final role = userRole;
      if (role == 'ADMINISTRATEUR') {
        Navigator.pushReplacementNamed(context, AdminRoutes.layout);
      } else if (role == 'ORGANISATEUR') {
        Navigator.pushReplacementNamed(context, OrganizerRoutes.layout);
      } else {
        Navigator.pushReplacementNamed(context, ClientRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AuthRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/utils/logo_icon.png',
              height: 100,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
