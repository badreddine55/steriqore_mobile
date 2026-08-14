import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialUser = await _checkAuth();
  runApp(SteriqoreApp(initialUser: initialUser));
}

Future<UserModel?> _checkAuth() async {
  final isLoggedIn = await AuthService.isLoggedIn();
  if (isLoggedIn) {
    return await AuthService.getUser();
  }
  return null;
}

class SteriqoreApp extends StatelessWidget {
  final UserModel? initialUser;

  const SteriqoreApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steriqore Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: initialUser != null
          ? DashboardScreen(user: initialUser!)
          : const LoginScreen(),
    );
  }
}
