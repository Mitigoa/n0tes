import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class RichTextEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String plainText, String richContent) onContentChanged;
  final TextEditingController? plainTextController;

  const RichTextEditor({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.plainTextController,
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

    return Column(
      children: [
        // Toolbar
        if (_isToolbarVisible)
          Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: QuillSimpleToolbar(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _quillController,
                showFontFamily: false,
                showFontSize: false,
                showHeaderStyle: false,
                showLink: false,
                showListNumbers: false,
                showQuote: false,
                showStrikeThrough: false,
                showInlineCode: false,
                showCodeBlock: false,
                showSearchButton: false,
                multiRowsDisplay: true,
              ),
            ),
          ),
        // Editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _quillController,
                placeholder: 'Start typing your note...',
                padding: const EdgeInsets.all(16),
                autoFocus: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
