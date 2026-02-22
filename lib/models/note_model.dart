import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
enum NoteType {
  @HiveField(0)
  text,
  @HiveField(1)
  checklist,
}

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String? folderId;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  int colorCode;

  @HiveField(6)
  bool isPinned;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  NoteType type;

  @HiveField(11)
  String? richContent; // Stores Quill Delta format as JSON string

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.folderId,
    required this.tags,
    required this.colorCode,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.type = NoteType.text,
    this.richContent,
  });
}
