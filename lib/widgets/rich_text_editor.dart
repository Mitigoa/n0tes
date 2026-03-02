import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class RichTextEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String plainText, String richContent) onContentChanged;
  final TextEditingController? plainTextController;
  final FocusNode? focusNode;

  const RichTextEditor({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.plainTextController,
    this.focusNode,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _quillController;
  final bool _isToolbarVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        // Try to parse as Delta (rich content)
        final deltaJson = jsonDecode(widget.initialContent!);
        _quillController = QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fall back to plain text
        _quillController = QuillController(
          document: Document()..insert(0, widget.initialContent ?? ''),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    _quillController.changes.listen((_) {
      _notifyContentChange();
    });
  }

  void _notifyContentChange() {
    final plainText = _quillController.document.toPlainText();
    final richContent =
        jsonEncode(_quillController.document.toDelta().toJson());

    widget.plainTextController?.text = plainText;
    widget.onContentChanged(plainText, richContent);
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Modern Toolbar
        if (_isToolbarVisible)
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: QuillSimpleToolbar(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _quillController,
                showFontFamily: false,
                showFontSize: false,
                showHeaderStyle: true,
                showLink: false,
                showListNumbers: true,
                showListBullets: true,
                showQuote: true,
                showStrikeThrough: true,
                showInlineCode: false,
                showCodeBlock: false,
                showSearchButton: false,
                showBoldButton: true,
                showItalicButton: true,
                showClearFormat: true,
                showAlignmentButtons: true,
                showSubscript: false,
                showSuperscript: false,
                showColorButton: true,
                showBackgroundColorButton: true,
                multiRowsDisplay: false,
              ),
            ),
          ),
        // Editor
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _quillController,
                placeholder: 'Start typing your note...',
                padding: const EdgeInsets.all(16),
                autoFocus: false,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
