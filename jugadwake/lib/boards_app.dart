import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/boards_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BoardsApp());
}

class BoardsApp extends StatelessWidget {
  const BoardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boards App',
      theme: AppTheme.themeData(),
      debugShowCheckedModeBanner: false,
      home: const BoardsScreen(),
    );
  }
}
