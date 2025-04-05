import 'package:flutter/material.dart';
import '../../components/buttons/custom_button.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const StepProgressIndicator(currentStep: 3),
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/images/success_icon.png',
                  width: 200,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have successfully created a new password,\nclick continue to enter the application',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                  );
                },
                enabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;

  const StepProgressIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const totalSteps = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          int step = (index ~/ 2) + 1;
          bool isCompleted = step < currentStep;
          bool isActive = step == currentStep;

          return CircleAvatar(
            radius: 14,
            backgroundColor:
                isCompleted || isActive ? Colors.blue : Colors.grey[800],
            child: Text(
              '$step',
              style: TextStyle(
                color: isCompleted || isActive ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          int prevStep = (index - 1) ~/ 2 + 1;

          return SizedBox(
            width: 30,
            height: 2,
            child: Stack(
              children: [
                Container(
                  width: 30,
                  height: 2,
                  color: Colors.grey[800],
                ),
                if (prevStep < currentStep)
                  Container(
                    width: 30,
                    height: 2,
                    color: Colors.blue,
                  )
                else if (prevStep == currentStep)
                  Container(
                    width: 15,
                    height: 2,
                    color: Colors.blue,
                  ),
              ],
            ),
          );
        }
      }),
    );
  }
}
