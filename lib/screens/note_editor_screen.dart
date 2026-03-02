import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
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

  // Focus nodes to preserve cursor position
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

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
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onContentChanged(String plainText, String richContent) {
    _plainContent = plainText;
    _richContent = richContent;
    _debounceSave();
  }

  void _onTitleChanged() {
    _debounceSave();
  }

  void _debounceSave() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() => _saveStatus = '...');

    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _saveNoteAsync();
    });
  }

  Future<void> _saveNoteAsync() async {
    final title = _titleController.text.trim();

    if (title.isEmpty && _plainContent.isEmpty) return;

    try {
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
      } else {
        await noteProvider.updateNote(note);
      }

      if (mounted) {
        setState(() => _saveStatus = 'Saved');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() => _saveStatus = '');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Error');
      }
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.color_lens,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Note Color',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ColorPicker(
                    selectedColor: _selectedColor,
                    onColorSelected: (color) {
                      setState(() => _selectedColor = color);
                      _saveNoteAsync();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.folder,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Select Folder',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_off_outlined, size: 20),
                  ),
                  title: const Text('No Folder'),
                  trailing: _selectedFolderId == null
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedFolderId = null);
                    _saveNoteAsync();
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: folderProvider.folders.length,
                    itemBuilder: (context, index) {
                      final folder = folderProvider.folders[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(folder.colorCode).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.folder,
                              color: Color(folder.colorCode), size: 20),
                        ),
                        title: Text(folder.name),
                        trailing: _selectedFolderId == folder.id
                            ? Icon(Icons.check,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          setState(() => _selectedFolderId = folder.id);
                          _saveNoteAsync();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined),
                  title: Text(_isPinned ? 'Unpin Note' : 'Pin Note'),
                  onTap: () {
                    setState(() => _isPinned = !_isPinned);
                    _saveNoteAsync();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: const Text('Move to Folder'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFolderSelector();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Change Color'),
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker();
                  },
                ),
                if (widget.note != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title:
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      context.read<NoteProvider>().deleteNote(_noteId);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate =
        DateTime(widget.note?.updatedAt.year ?? now.year, widget.note?.updatedAt.month ?? now.month, widget.note?.updatedAt.day ?? now.day);

    if (noteDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(widget.note?.updatedAt ?? now)}';
    }
    return DateFormat('MMM d, y • h:mm a').format(widget.note?.updatedAt ?? now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _saveNoteAsync();
        }
      },
      child: Scaffold(
        backgroundColor: _selectedColor == 0xFFFFFFFF
            ? theme.scaffoldBackgroundColor
            : isDark
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.6), Color(_selectedColor))
                : Color(_selectedColor),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () async {
                await _saveNoteAsync();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          actions: [
            // Save status indicator
            if (_saveStatus.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _saveStatus == 'Saved'
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_saveStatus == '...')
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else if (_saveStatus == 'Saved')
                      Icon(Icons.check_circle, size: 14, color: Colors.green[700])
                    else
                      Icon(Icons.error_outline, size: 14, color: Colors.red[700]),
                    const SizedBox(width: 6),
                    Text(
                      _saveStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _saveStatus == 'Saved'
                            ? Colors.green[700]
                            : _saveStatus == 'Error'
                                ? Colors.red[700]
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            // Pin button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _isPinned
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: _isPinned
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                tooltip: 'Pin note',
                onPressed: () {
                  setState(() => _isPinned = !_isPinned);
                  _saveNoteAsync();
                },
              ),
            ),
            const SizedBox(width: 8),
            // More options button
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showMoreOptions,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date info
              if (widget.note != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Title input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _onTitleChanged(),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_contentFocusNode);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Rich text editor
              Expanded(
                child: RichTextEditor(
                  initialContent:
                      _richContent.isNotEmpty ? _richContent : _plainContent,
                  plainTextController: _plainTextController,
                  focusNode: _contentFocusNode,
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
