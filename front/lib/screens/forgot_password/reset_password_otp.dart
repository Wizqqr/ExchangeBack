import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/inputs/custom_text_field.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;
  const ResetPasswordOTPScreen({super.key, required this.email});

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isCodeWrong = false;
  bool isButtonEnabled = false;
  bool canResend = false;
  bool isMailOpened = false;
  int secondsRemaining = 0;
  Timer? _timer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final String correctCode = '111111';

  @override
  void initState() {
    super.initState();
    _startTimer();

    for (var controller in controllers) {
      controller.addListener(_checkFieldsFilled);
    }

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      secondsRemaining = 60;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsRemaining--;
        if (secondsRemaining <= 0) {
          canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _checkFieldsFilled() {
    final filled = controllers.every((c) => c.text.trim().isNotEmpty);
    if (filled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = filled;
      });
    }
  }

  void _clearAllFields() {
    for (var controller in controllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    setState(() {
      isButtonEnabled = false;
    });
  }

  void _verifyCode() {
    final enteredCode = controllers.map((c) => c.text.trim()).join();
    if (enteredCode == correctCode) {
      // Сначала сбрасываем поля и состояния
      for (var controller in controllers) {
        controller.clear();
      }

      focusNodes[0].requestFocus();

      setState(() {
        isMailOpened = true;
        isCodeWrong = false;
        isButtonEnabled = false;
      });

      // Небольшая задержка — показать открытую почту
      Future.delayed(const Duration(milliseconds: 1000), () {
        // ❗ После перехода сбросим isMailOpened
        setState(() {
          isMailOpened = false;
        });

        Navigator.pushNamed(context, '/new-password').then((_) {
          // Когда вернёмся назад — сбрасываем снова
          for (var controller in controllers) {
            controller.clear();
          }
          focusNodes[0].requestFocus();
          setState(() {
            isMailOpened = false;
            isCodeWrong = false;
            isButtonEnabled = false;
          });
        });
      });
    } else {
      setState(() {
        isCodeWrong = true;
      });
      _shakeController.forward(from: 0);
      _clearAllFields();
    }
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 45,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: Focus(
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.backspace) &&
              controllers[index].text.isEmpty &&
              index > 0) {
            focusNodes[index - 1].requestFocus();
            controllers[index - 1].clear();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.grey[900],
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: controllers[index].text.isNotEmpty
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              focusNodes[index + 1].requestFocus();
            }
            setState(() {
              isCodeWrong = false;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const StepProgressIndicator(currentStep: 2),
                const SizedBox(height: 32),
                const Text(
                  'Please enter the code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent email to ${widget.email}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Image.asset(
                  isMailOpened
                      ? 'assets/images/mail_icon_opened.png'
                      : 'assets/images/mail_icon_closed.png',
                  width: 60,
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, _buildOTPField),
                  ),
                ),
                const SizedBox(height: 16),
                if (isCodeWrong)
                  const Text(
                    'Incorrect code. Try again.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                canResend
                    ? TextButton(
                        onPressed: _startTimer,
                        child: const Text("Send again",
                            style: TextStyle(color: Colors.blue)),
                      )
                    : Text(
                        "Send again in $secondsRemaining sec",
                        style: const TextStyle(color: Colors.white60),
                      ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Entered',
                  onPressed: _verifyCode,
                  enabled: isButtonEnabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep; // 1, 2 или 3

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
          int leftStep = (index - 1) ~/ 2 + 1;
          bool isLineCompleted = leftStep < currentStep;

          return Container(
            width: 30,
            height: 2,
            color: isLineCompleted ? Colors.blue : Colors.grey[800],
          );
        }
      }),
    );
  }
}
