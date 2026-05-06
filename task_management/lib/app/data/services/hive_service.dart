import 'package:hive/hive.dart';

import '../models/task_model.dart';

class HiveService {
  HiveService._();

  static const String _taskBox = 'tasks';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_taskBox)) {
      await Hive.openBox<TaskModel>(_taskBox);
    }
  }

  static Box<TaskModel> get _box => Hive.box<TaskModel>(_taskBox);

  static List<TaskModel> getTasks() {
    return _box.values.toList();
  }

  static Future<void> addTask(TaskModel task) async {
    await _box.add(task);
  }

  static Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  static Future<void> deleteTask(TaskModel task) async {
    await task.delete();
  }
}
