import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  TaskModel({
    required this.title,
    required this.priority,
    required this.energyLevel,
    required this.isCompleted,
    required this.dueDate,
  });

  @HiveField(0)
  String title;

  @HiveField(1)
  int priority;

  @HiveField(2)
  int energyLevel;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime dueDate;
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TaskModel(
      title: fields[0] as String,
      priority: fields[1] as int,
      energyLevel: fields[2] as int,
      isCompleted: fields[3] as bool,
      dueDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.energyLevel)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.dueDate);
  }
}
