import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routes/app_router.dart';
import 'core/assets/app_colors.dart';
import 'core/api/dio_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ontik',
      theme: AppTheme.light,
      initialRoute: '/login',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
