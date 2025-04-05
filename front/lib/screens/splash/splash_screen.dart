import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;
  late Animation<Color?> _colorAnimation;

  void _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seenOnBoarding'); // или prefs.setBool('seenOnBoarding', false);
  }

  @override
  void initState() {
    super.initState();

    _resetOnboarding();

    _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    _navigate(); // заменяем Timer
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnBoarding') ?? false;

    if (!seen) {
        Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
        Navigator.pushReplacementNamed(context, '/');
    }
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: Colors.grey[900],
      end: Theme.of(context).scaffoldBackgroundColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox.expand(
            child: Container(
              color: _colorAnimation.value,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                                spreadRadius: 12,
                                blurRadius: 100,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Exchanger',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}