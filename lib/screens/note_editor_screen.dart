import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../providers/folder_provider.dart';
import '../widgets/color_picker.dart';
import '../widgets/rich_text_editor.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _plainTextController;
  Timer? _debounce;
  String _saveStatus = '';
  String _richContent = '';
  String _plainContent = '';

  late String _noteId;
  late int _selectedColor;
  bool _isPinned = false;
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _noteId = widget.note?.id ?? const Uuid().v4();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _plainTextController =
        TextEditingController(text: widget.note?.content ?? '');
    _richContent = widget.note?.richContent ?? '';
    _plainContent = widget.note?.content ?? '';
    _selectedColor = widget.note?.colorCode ?? 0xFFFFFFFF;
    _isPinned = widget.note?.isPinned ?? false;
    _selectedFolderId = widget.note?.folderId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _plainTextController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onContentChanged(String plainText, String richContent) {
    _plainContent = plainText;
    _richContent = richContent;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveNoteAsync();
    });
  }

  void _onTitleChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveNoteAsync();
    });
  }

  Future<void> _saveNoteAsync() async {
    final title = _titleController.text.trim();

    if (title.isEmpty && _plainContent.isEmpty) return;

    setState(() => _saveStatus = 'Saving...');

    try {
      print('NoteEditor: _saveNoteAsync starting id=$_noteId title="$title"');
      final noteProvider = context.read<NoteProvider>();
      final isNewNote = widget.note == null &&
          noteProvider.notes.where((n) => n.id == _noteId).isEmpty;

      final note = Note(
        id: _noteId,
        title: title,
        content: _plainContent,
        richContent: _richContent,
        folderId: _selectedFolderId,
        tags: widget.note?.tags ?? [],
        colorCode: _selectedColor,
        isPinned: _isPinned,
        isArchived: widget.note?.isArchived ?? false,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        type: NoteType.text,
      );

      if (isNewNote) {
        await noteProvider.addNote(note);
        print('NoteEditor: addNote awaited for id=${note.id}');
      } else {
        await noteProvider.updateNote(note);
        print('NoteEditor: updateNote awaited for id=${note.id}');
      }

      setState(() => _saveStatus = 'Saved');
      print('NoteEditor: Save completed id=${note.id}');
      // Clear status after 1 second
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _saveStatus = '');
      }
    } catch (e) {
      print('NoteEditor: Save error: $e');
      setState(() => _saveStatus = 'Error saving');
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();

    if (title.isEmpty && _plainContent.isEmpty) return;

    final noteProvider = context.read<NoteProvider>();
    final isNewNote = widget.note == null &&
        noteProvider.notes.where((n) => n.id == _noteId).isEmpty;

    final note = Note(
      id: _noteId,
      title: title,
      content: _plainContent,
      richContent: _richContent,
      folderId: _selectedFolderId,
      tags: widget.note?.tags ?? [],
      colorCode: _selectedColor,
      isPinned: _isPinned,
      isArchived: widget.note?.isArchived ?? false,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      type: NoteType.text,
    );

    if (isNewNote) {
      noteProvider.addNote(note);
    } else {
      noteProvider.updateNote(note);
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Color',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ColorPicker(
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                    _saveNote();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFolderSelector() {
    final folderProvider = context.read<FolderProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Folder',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('No Folder'),
                trailing:
                    _selectedFolderId == null ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _selectedFolderId = null);
                  _saveNote();
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folderProvider.folders.length,
                  itemBuilder: (context, index) {
                    final folder = folderProvider.folders[index];
                    return ListTile(
                      leading:
                          Icon(Icons.folder, color: Color(folder.colorCode)),
                      title: Text(folder.name),
                      trailing: _selectedFolderId == folder.id
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        setState(() => _selectedFolderId = folder.id);
                        _saveNote();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Color(_selectedColor);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedColor == 0xFFFFFFFF) {
      bgColor = Theme.of(context).scaffoldBackgroundColor;
    } else if (isDark) {
      bgColor = Color.alphaBlend(Colors.black.withValues(alpha: 0.6), bgColor);
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _saveNoteAsync();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveNoteAsync();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: _saveStatus.isNotEmpty
              ? Text(
                  _saveStatus,
                  style: TextStyle(
                    fontSize: 14,
                    color: _saveStatus == 'Saved'
                        ? Colors.green
                        : _saveStatus == 'Error saving'
                            ? Colors.red
                            : Colors.orange,
                  ),
                )
              : null,
          actions: [
            IconButton(
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              tooltip: 'Pin note',
              onPressed: () {
                setState(() => _isPinned = !_isPinned);
                _saveNote();
              },
            ),
            IconButton(
              icon: const Icon(Icons.color_lens_outlined),
              tooltip: 'Change color',
              onPressed: _showColorPicker,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'folder':
                    _showFolderSelector();
                    break;
                  case 'delete':
                    if (widget.note != null) {
                      context.read<NoteProvider>().deleteNote(_noteId);
                      Navigator.pop(context);
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'folder',
                  child: Row(
                    children: [
                      Icon(Icons.create_new_folder_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Move to folder'),
                    ],
                  ),
                ),
                if (widget.note != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Title input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _onTitleChanged(),
                ),
              ),
              const Divider(height: 1),
              // Rich text editor
              Expanded(
                child: RichTextEditor(
                  initialContent:
                      _richContent.isNotEmpty ? _richContent : _plainContent,
                  plainTextController: _plainTextController,
                  onContentChanged: _onContentChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
