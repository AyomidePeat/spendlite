import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/currency_provider.dart';
import 'package:spendlite/home_screen.dart';
import 'package:spendlite/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(child: SpendLiteApp()));
}

class SpendLiteApp extends ConsumerStatefulWidget {
  const SpendLiteApp({super.key});

  static const Color primaryColor = Color(0xFF8B5CF6); 
  static const Color accentColor = Color(0xFFFACC15); 
  static const Color cardColor = Color(0xFF1F2937); 
  static const Color backgroundColor = Color(0xFF111827); 

  @override
  ConsumerState<SpendLiteApp> createState() => _SpendLiteAppState();
}

class _SpendLiteAppState extends ConsumerState<SpendLiteApp> {
  @override
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendLite',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, 
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: SpendLiteApp.primaryColor,
        colorScheme: const ColorScheme.dark(
          primary: SpendLiteApp.primaryColor,
          secondary: SpendLiteApp.accentColor,
          surface: SpendLiteApp.cardColor,
          background: SpendLiteApp.backgroundColor,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: SpendLiteApp.backgroundColor,
        cardColor: SpendLiteApp.cardColor,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: SpendLiteApp.backgroundColor,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: SpendLiteApp.primaryColor,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        // cardTheme:  CardTheme(
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );
  }
}