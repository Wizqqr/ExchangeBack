import 'package:flutter/material.dart';
import '../../components/buttons/custom_button.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkForm);
    _confirmController.addListener(_checkForm);
  }

  void _checkForm() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _isValid = _validatePassword(password) && password == confirm;
    });
  }

  bool _validatePassword(String password) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~%^(),.?":{}|<>]').hasMatch(password);
    return password.length >= 8 && hasUpper && hasNumber && hasSpecial;
  }

  void _onContinue() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/password-reset-success',
      (route) => false, // это удалит все предыдущие роуты
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true, // ✅ позволяет экрану адаптироваться
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    // 💡 Это ключ, чтобы работало без Expanded
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const StepProgressIndicator(currentStep: 3),
                        const SizedBox(height: 32),
                        const Text(
                          'Create a password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The password must be 8 characters, including 1 uppercase letter, 1 number and 1 special character.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        _buildPasswordField(
                          _passwordController,
                          'Password',
                          _showPassword,
                          () => setState(() => _showPassword = !_showPassword),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Confirm password',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          _confirmController,
                          'Password',
                          _showConfirm,
                          () => setState(() => _showConfirm = !_showConfirm),
                        ),

                        // 👇 Spacer работает правильно внутри обычного Column
                        const SizedBox(height: 24),
                        Expanded(child: Container()),

                        CustomButton(
                          text: 'Continue',
                          onPressed: _isValid ? _onContinue : () {},
                          enabled: _isValid,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 64
                              : 32,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool visible,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
