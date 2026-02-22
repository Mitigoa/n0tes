import 'package:hive/hive.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 3)
class Tag extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int usageCount;

  Tag({
    required this.name,
    this.usageCount = 0,
  });
}
