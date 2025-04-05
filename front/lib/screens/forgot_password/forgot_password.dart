import 'package:flutter/material.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/inputs/custom_text_field.dart'; 

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _isFormFilled = _emailController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.pushNamed(
      context,
      '/confirm-email',
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black, // тёмный фон
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  StepCircle(number: 1, isActive: true),
                  StepDivider(),
                  StepCircle(number: 2),
                  StepDivider(),
                  StepCircle(number: 3),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Password reset',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please enter your registered email address to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _emailController,
                hintText: 'Email address',
                inputFormatters: [], // Убрал числовой фильтр для email
              ),

              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: _onContinue,
                enabled: _isFormFilled,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// StepCircle и StepDivider остаются без изменений
class StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;

  const StepCircle({super.key, required this.number, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: isActive ? Colors.blue : Colors.grey[700],
      child: Text(
        '$number',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class StepDivider extends StatelessWidget {
  const StepDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 2,
      color: Colors.grey[700],
    );
  }
}
