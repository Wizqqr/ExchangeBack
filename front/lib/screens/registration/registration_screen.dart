import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../components/buttons/custom_button.dart';
import '../../models/user.dart';
import '../../logo/custom_logo.dart';
import '../../styles/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_checkFormFilled);
    passwordController.addListener(_checkFormFilled);
    confirmPasswordController.addListener(_checkFormFilled);
    phoneController.addListener(_checkFormFilled);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _checkFormFilled() {
    final filled = usernameController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        phoneController.text.trim().isNotEmpty;

    if (filled != _isFormFilled) {
      setState(() {
        _isFormFilled = filled;
      });
    }
  }

  void _register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final phone = phoneController.text.trim();

    if (username.isEmpty || password.isEmpty || phone.isEmpty) {
      setState(() => _errorText = 'Заполните все поля');
      return;
    }

    if (username.length < 3) {
      setState(() =>
          _errorText = 'Имя пользователя должно содержать минимум 3 символа');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorText = 'Пароль должен содержать минимум 8 символов');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorText = 'Пароли не совпадают');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Временно переходим на /otp с email
    Navigator.pushReplacementNamed(
      context,
      '/otp',
      arguments: phone,
    );

    //MARK: - Тут будет реальный запрос
    // try {
    //   final success = await ApiService.register(username, password, phone);
    //   if (success) {
    //     Navigator.pushReplacementNamed(context, '/otp', arguments: phone);
    //   } else {
    //     setState(() => _errorText = 'Ошибка регистрации');
    //   }
    // } catch (e) {
    //   setState(() => _errorText = 'Ошибка: $e');
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Center(child: CustomLogo()), // Центрируем логотип
                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,
                  decoration:
                      const InputDecoration(labelText: 'Имя пользователя'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Повторите пароль'),
                ),
                const SizedBox(height: 16),

                if (_errorText != null)
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),

                CustomButton(
                  onPressed: _isFormFilled ? _register : () {},
                  enabled: _isFormFilled,
                  text: 'Зарегистрироваться',
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Уже есть аккаунт? Войти'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
