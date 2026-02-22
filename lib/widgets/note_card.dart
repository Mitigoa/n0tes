import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/folder_model.dart';
import '../utils/date_formatter.dart';
import '../utils/constants.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Folder? folder;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    Key? key,
    required this.note,
    this.folder,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine card color: use note's color code if not white, else default theme card color
    Color cardColor = Color(note.colorCode);
    if (note.colorCode == 0xFFFFFFFF) {
      cardColor = theme.cardTheme.color ?? theme.cardColor;
    } else {
      // Adjust color for dark mode to be less harsh if dark theme
      if (isDark) {
        cardColor = Color.alphaBlend(Colors.black.withOpacity(0.6), cardColor);
      }
    }

    final textColor = (note.colorCode != 0xFFFFFFFF && !isDark)
        ? Colors.black87
        : theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Card(
      color: cardColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // For staggered grid
            children: [
              if (note.title.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      Icon(Icons.push_pin,
                          size: 16, color: textColor.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (note.content.isNotEmpty) ...[
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(height: 12),
              ],
              if (folder != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(folder!.colorCode).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder,
                        size: 10,
                        color: Color(folder!.colorCode),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        folder!.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(folder!.colorCode),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormatter.formatWithTime(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (DateFormatter.isRecentlyUpdated(
                            note.createdAt, note.updatedAt))
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Updated',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade600,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (note.tags.isNotEmpty)
                    Icon(Icons.label_outline,
                        size: 12, color: textColor.withOpacity(0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
