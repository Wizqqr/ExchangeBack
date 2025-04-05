import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/buttons/custom_button.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String correctCode = '111111';
  bool isCodeWrong = false;
  bool isButtonEnabled = false;
  bool canResend = false;
  bool isMailOpened = false;
  int secondsRemaining = 0;
  Timer? _timer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
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
    _shakeController.dispose(); // вот это добавь
    super.dispose();
  }

  void _checkFieldsFilled() {
    final filled = controllers.every((c) => c.text.trim().isNotEmpty);
    if (filled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = filled;
      });
    }
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
      setState(() {
        isMailOpened = true;
      });

      // Ждём 2 секунды, потом переходим
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/main');
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
            controllers[index - 1].clear(); // очищаем предыдущий
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: controllers[index].text.isNotEmpty
                    ? Colors.blue
                    : Colors.grey,
              ),
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/'); // или '/register'
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Пожалуйста, введите код',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Мы отправили сообщение на\nваш email: ${widget.email}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Image.asset(
                  isMailOpened
                      ? 'assets/images/mail_icon_opened.png'
                      : 'assets/images/mail_icon_closed.png',
                  width: 57,
                  height: 60,
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
                    'Неверный код. Попробуйте снова.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                canResend
                    ? TextButton(
                        onPressed: _startTimer,
                        child: const Text('Отправить снова'),
                      )
                    : Text(
                        "Отправить снова через $secondsRemaining сек",
                        style: const TextStyle(color: Colors.grey),
                      ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: _verifyCode,
                  text: 'Подтвердить',
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
