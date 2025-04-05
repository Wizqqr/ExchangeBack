// Создайте новый файл: lib/services/event_bus.dart

import 'dart:async';

/// Шина событий для передачи сообщений между компонентами приложения
class EventBus {
  static final EventBus _instance = EventBus._internal();
  
  factory EventBus() => _instance;
  
  EventBus._internal();
  
  final StreamController _streamController = StreamController.broadcast();
  
  /// Поток событий
  Stream get stream => _streamController.stream;
  
  /// Отправить событие в шину
  static void fire(event) {
    _instance._streamController.add(event);
  }
  
  /// Подписаться на события
  StreamSubscription listen(Function(dynamic) onData) {
    return _streamController.stream.listen(onData);
  }
  
  /// Закрыть шину событий
  void dispose() {
    _streamController.close();
  }
}

/// Событие обновления экрана кассы
class RefreshCashEvent {}