# exchanger

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



✅ README.md для твоего проекта
markdown
Копировать
Редактировать
# 💱 Flutter + Django Exchange App

Проект представляет собой клиент-серверное приложение для обмена валют:
- 📱 **Frontend:** Flutter
- 🛠️ **Backend:** Django REST Framework + JWT
- 📦 Авторизация, события, список валют, админка и управление пользователями

---

## 📁 Структура проекта

project-root/ ├── backend/ # Django REST API │ ├── exchange_api/ │ ├── requirements.txt │ └── venv/ # Виртуальное окружение (можно игнорировать в git) └── frontend/ # Flutter-приложение

yaml
Копировать
Редактировать

---

## 🚀 Запуск Backend (Django)

1. Перейди в папку `backend`:

   ```bash
   cd backend
Создай и активируй виртуальное окружение:

bash
Копировать
Редактировать
python -m venv venv
source venv/bin/activate      # Mac/Linux
venv\Scripts\activate         # Windows
Установи зависимости:

bash
Копировать
Редактировать
pip install -r requirements.txt
Убедись, что установлены django-cors-headers и djangorestframework-simplejwt. Если нет:

bash
Копировать
Редактировать
pip install django-cors-headers djangorestframework-simplejwt
Выполни миграции:

bash
Копировать
Редактировать
python manage.py migrate
Запусти сервер (локально):

bash
Копировать
Редактировать
python manage.py runserver
Если хочешь, чтобы сервер был доступен в сети:

bash
Копировать
Редактировать
python manage.py runserver 0.0.0.0:8000
🧪 Тестовые пользователи (если есть)
Создай суперпользователя для входа в админку:

bash
Копировать
Редактировать
python manage.py createsuperuser
📱 Запуск Frontend (Flutter)
Перейди в папку frontend:

bash
Копировать
Редактировать
cd frontend
Установи зависимости:

bash
Копировать
Редактировать
flutter pub get
Укажи правильный baseUrl в api_service.dart:

dart
Копировать
Редактировать
static const String _baseUrl = 'http://127.0.0.1:8000'; // для iOS-симулятора

// или
static const String _baseUrl = 'http://192.168.X.X:8000'; // если тест на физическом устройстве
Запусти проект:

bash
Копировать
Редактировать
flutter run
Или с указанием устройства:

bash
Копировать
Редактировать
flutter run -d ios     # для Xcode симулятора
flutter run -d android # для Android эмулятора
❗️ Важно
iOS-симулятор может использовать http://127.0.0.1:8000

Android-эмулятор — http://10.0.2.2:8000

Физическое устройство — IP компьютера (например http://192.168.1.5:8000), с запущенным сервером на 0.0.0.0

🔐 Авторизация
Используется JWT (/token и /token/refresh).
Токены автоматически сохраняются через flutter_secure_storage.

🧑‍💻 Технологии
Django REST Framework

JWT авторизация (simplejwt)

CORS middleware

Flutter (Material + Cupertino)

Flutter Secure Storage

HTTP requests

