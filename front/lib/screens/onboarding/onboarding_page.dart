import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exchanger/components/buttons/custom_button.dart';

class OnBoardingPage extends StatelessWidget {
   OnBoardingPage({super.key});

   final introKey = GlobalKey<IntroductionScreenState>();

   void _onIntroEnd(BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnBoarding', true);
      Navigator.of(context).pushReplacementNamed('/');
   }

   Widget _buildImage(String assetName) {
      return Center(
         child: Image.asset('assets/onboarding_img/$assetName', height: 220),
      );
   }

   @override
   Widget build(BuildContext context) {
      return IntroductionScreen(
         key: introKey,
         globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
         pages: [
            PageViewModel(
               title: "Добро пожаловать в Exchanger",
               body: "Обменивай валюту легко, быстро и удобно прямо с телефона.",
               image: _buildImage('img.png'),
               decoration: _getPageDecoration(context),
            ),
            PageViewModel(
               title: "Добавляй свои курсы",
               body: "Устанавливай и редактируй курсы обмена вручную.",
               image: _buildImage('img_1.png'),
               decoration: _getPageDecoration(context),
            ),
            PageViewModel(
               title: "Находи лучшие предложения",
               body: "Следи за актуальными курсами и находи самые выгодные.",
               image: _buildImage('img_2.png'),
               decoration: _getPageDecoration(context),
               footer: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomButton(
                     text: 'Начать',
                     onPressed: () => _onIntroEnd(context),
                  ),
               ),
            ),
         ],
         onDone: () {}, // не нужен, используем кастомную кнопку
         showDoneButton: false,
         showSkipButton: true,
         skip: Text('Пропустить', style: TextStyle(color: Theme.of(context).primaryColor)),
         next: const Icon(Icons.arrow_forward, color: Colors.white),
         dotsDecorator: DotsDecorator(
            activeColor: Theme.of(context).primaryColor,
            color: Colors.grey.shade700,
            size: const Size(10.0, 10.0),
            activeSize: const Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(24.0),
            ),
         ),
      );
   }

   PageDecoration _getPageDecoration(BuildContext context) {
      return PageDecoration(
         titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
         ),
         bodyTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey[300],
         ),
         imagePadding: const EdgeInsets.only(top: 32),
         contentMargin: const EdgeInsets.symmetric(horizontal: 20),
      );
   }
}
