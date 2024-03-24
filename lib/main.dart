import 'package:flutter/material.dart';
import 'package:inkwel_blog_app/core/theme/theme.dart';
import 'package:inkwel_blog_app/features/auth/presentation/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkwel - Blog App',
      theme: AppTheme.darkThemeMode,
      home: const SignUpPage(),
    );
  }
}
