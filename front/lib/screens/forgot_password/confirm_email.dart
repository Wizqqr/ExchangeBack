import 'package:flutter/material.dart';
import '../../components/buttons/custom_button.dart';

class ConfirmEmailScreen extends StatelessWidget {
  final String email;

  const ConfirmEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Тёмный фон
      appBar: AppBar(
        leading: const BackButton(color: Colors.white), // Белая стрелка
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepProgressIndicator(currentStep: 1),
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/images/email_illustration.png',
                  width: 220,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Confirm your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We just sent you an email to\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Confirm',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/reset-password-otp',
                    arguments: email,
                  );
                },
                enabled: true,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email sent again')),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "I ",
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: "didn’t receive",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: " my email",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
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
                isCompleted || isActive ? Colors.blue : Colors.grey[700],
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
                  color: Colors.grey[700],
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
