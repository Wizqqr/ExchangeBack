import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:exchanger/screens/home/home_screen.dart';
import 'package:exchanger/screens/events/events_screen.dart';
import 'package:exchanger/screens/cash_register/cash_screen.dart';
import 'package:exchanger/screens/currencies/currencies_screen.dart';
import 'package:exchanger/models/user.dart';
import 'package:exchanger/services/api_service.dart';
import 'package:exchanger/styles/app_theme.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  bool? _isSuperAdmin;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const CashScreen(),
    const CurrenciesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  Future<void> _checkSuperUser() async {
    final username = UserManager().getCurrentUser();
    if (username != null) {
      final result = await ApiService.isSuperUser(username);
      if (mounted) {
        setState(() {
          _isSuperAdmin = result;
        });
      }
    }
  }

  Future<void> showLogoutConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Выход из аккаунта'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  // Выполняем выход
                  ApiService.clearSuperUserCache();
                  UserManager().setCurrentUser(null);
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Выйти'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Выход из аккаунта'),
            content: Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(
                child: Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Выйти'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Выполняем выход
                  ApiService.clearSuperUserCache();
                  UserManager().setCurrentUser(null);
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Обновленный AppBar в MainTabScreen

@override
Widget build(BuildContext context) {
  final username = UserManager().getCurrentUser();
  
  // Получаем заголовок в зависимости от выбранной вкладки
  String title = 'Обменник отчеты';
  switch (_selectedIndex) {
    case 0:
      title = 'Обменник отчеты';
      break;
    case 1:
      title = 'События';
      break;
    case 2:
      title = 'Касса';
      break;
    case 3:
      title = 'Валюты';
      break;
  }
  
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Убираем автоматическую кнопку назад
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              showLogoutConfirmationDialog(context);
            },
          ),
        ),
      ],
    ),
    extendBodyBehindAppBar: true,
    body: IndexedStack(
      index: _selectedIndex,
      children: _screens,
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'События',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.money_sharp),
          label: 'Касса',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: 'Валюты',
        ),
      ],
    ),
  );
}
}