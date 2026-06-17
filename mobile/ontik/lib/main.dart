import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routes/auth_routes.dart';
import 'core/routes/app_router.dart';
import 'core/assets/app_colors.dart';
import 'core/api/dio_config.dart';
import 'core/services/app_config.dart';
import 'generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await loadAppConfig();
  await initializeDateFormatting(appLanguage == 'en' ? 'en_US' : 'fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    appConfigNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    appConfigNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ontik',
      locale: Locale(appLanguage),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('fr');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return const Locale('fr');
      },
      theme: resolveTheme(),
      initialRoute: AuthRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
