// Создайте новый файл lib/components/refreshable_state.dart

import 'package:flutter/material.dart';

/// Миксин для состояний, которые могут обновлять свои данные
mixin RefreshableState<T extends StatefulWidget> on State<T> {
  /// Метод для обновления данных
  void refreshData();
}