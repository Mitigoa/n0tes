import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import '../utils/constants.dart';

class FolderChip extends StatelessWidget {
  final Folder folder;
  final bool isSelected;
  final VoidCallback? onTap;

  const FolderChip({
    Key? key,
    required this.folder,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final folderColor = Color(folder.colorCode);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      avatar: Icon(
        Icons.folder,
        size: 16,
        color: isSelected ? (isDark ? Colors.black : Colors.white) : folderColor,
      ),
      label: Text(
        folder.name,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? (isDark ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? folderColor : theme.cardColor,
      side: BorderSide(
        color: isSelected ? Colors.transparent : theme.dividerColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      onPressed: onTap ?? () {},
    );
  }
}
