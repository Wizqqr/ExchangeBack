import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
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
         title: 'Exchanger',
         theme: AppTheme.darkTheme,
         initialRoute: '/splash',
         routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => const LoginScreen(),
            '/main': (context) => const HomeScreen(),
            '/onboarding': (context) => OnBoardingPage(), // добавь этот маршрут
         },
      );
   }
}


