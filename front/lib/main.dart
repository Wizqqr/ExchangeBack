import 'package:exchanger/screens/registration/registration_screen.dart';
import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'package:exchanger/screens/main_tab_screen.dart';
import 'screens/registration/otp_screen.dart';
import 'screens/forgot_password/forgot_password.dart';
import 'screens/forgot_password/confirm_email.dart';
import 'screens/forgot_password/reset_password_otp.dart';
import 'screens/forgot_password/new_password.dart';
import 'screens/forgot_password/password_have_changed.dart';
import 'screens/onboarding/onboarding_page.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();

   final prefs = await SharedPreferences.getInstance();
   final seen = prefs.getBool('seenOnBoarding') ?? false;

   runApp(MyApp(showOnBoarding: !seen));
}

class MyApp extends StatelessWidget {
   final bool showOnBoarding;

   const MyApp({super.key, required this.showOnBoarding}); // <- добавил

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => OTPScreen(email: email),
          );
        }
        if (settings.name == '/confirm-email') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ConfirmEmailScreen(email: email),
          );
        }
        if (settings.name == '/reset-password-otp') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordOTPScreen(email: email),
          );
        }
        return null;
      },
      title: 'Exchanger',
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const RegisterScreen(),
        '/main': (context) => const MainTabScreen(),
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/new-password': (context) => const NewPasswordScreen(),
        '/password-reset-success': (context) => const PasswordResetSuccessScreen(),
        '/onboarding': (context) => OnBoardingPage(),
      },
    );
  }
}
