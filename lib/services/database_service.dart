import 'package:hive_flutter/hive_flutter.dart';

/// Hive Database Service (mirrors flutter_gems DatabaseService pattern)
class DatabaseService {
  static const String _defaultBoxName = 'robodoc_database';
  Box? _defaultBox;
  final Map<String, Box> _boxes = {};

  Future<void> initialize({String? boxName}) async {
    await Hive.initFlutter();
    _defaultBox = await Hive.openBox(boxName ?? _defaultBoxName);
  }

  Future<Box> openBox(String boxName) async {
    if (_boxes.containsKey(boxName)) return _boxes[boxName]!;
    final box = await Hive.openBox(boxName);
    _boxes[boxName] = box;
    return box;
  }

  Box get box {
    final b = _defaultBox;
    if (b == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return b;
  }

  Future<void> save<T>(String key, T value, {String? boxName}) async {
    final targetBox = boxName != null ? await openBox(boxName) : box;
    await targetBox.put(key, value);
  }

  T? get<T>(String key, {String? boxName}) {
    final targetBox = boxName != null ? _boxes[boxName] : box;
    if (targetBox == null) return null;
    return targetBox.get(key) as T?;
  }

  bool containsKey(String key, {String? boxName}) {
    final targetBox = boxName != null ? _boxes[boxName] : box;
    if (targetBox == null) return false;
    return targetBox.containsKey(key);
  }

  Future<void> delete(String key, {String? boxName}) async {
    final targetBox = boxName != null ? await openBox(boxName) : box;
    await targetBox.delete(key);
  }
}

