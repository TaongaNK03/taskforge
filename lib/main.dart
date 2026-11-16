import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const TaskForgeApp());
}

class TaskForgeApp extends StatelessWidget {
  const TaskForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TaskForge',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData(brightness: Brightness.light).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3559C7),
            brightness: Brightness.light,
            primary: const Color(0xFF3559C7),
            surface: const Color(0xFFFFFFFF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F6F8),
          dividerColor: const Color(0xFFE8EAF0),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3559C7), width: 1.5)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 70,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE9EDFA),
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7894F4),
            brightness: Brightness.dark,
            primary: const Color(0xFF3B82F6),
            surface: const Color(0xFF131B2E),
          ),
          scaffoldBackgroundColor: const Color(0xFF10141D),
          dividerColor: const Color(0xFF293141),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF171D29),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF293141))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7894F4), width: 1.5)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 70,
            backgroundColor: const Color(0xFF171D29),
            indicatorColor: const Color(0xFF27324A),
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
