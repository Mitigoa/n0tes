import 'package:hive/hive.dart';

part 'folder_model.g.dart';

@HiveType(typeId: 2)
class Folder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorCode;

  @HiveField(3)
  int noteCount;

  @HiveField(4)
  DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.colorCode,
    this.noteCount = 0,
    required this.createdAt,
  });
}
