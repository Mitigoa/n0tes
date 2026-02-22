import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note_model.dart';
import '../models/folder_model.dart';
import 'note_card.dart';

class NoteGrid extends StatelessWidget {
  final List<Note> notes;
  final List<Folder> folders;
  final Function(Note) onTap;
  final Function(Note) onLongPress;
  final bool isGridView;
  final bool
      asSliver; // if true, build sliver widgets instead of normal widgets

  const NoteGrid({
    Key? key,
    required this.notes,
    required this.folders,
    required this.onTap,
    required this.onLongPress,
    this.isGridView = true,
    this.asSliver = false,
  }) : super(key: key);

  Folder? _getFolderForNote(Note note) {
    if (note.folderId == null) return null;
    try {
      return folders.firstWhere((f) => f.id == note.folderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build sliver widgets when requested
    if (asSliver) {
      if (notes.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (!isGridView) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final note = notes[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: NoteCard(
                  note: note,
                  folder: _getFolderForNote(note),
                  onTap: () => onTap(note),
                  onLongPress: () => onLongPress(note),
                ),
              );
            },
            childCount: notes.length,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              folder: _getFolderForNote(note),
              onTap: () => onTap(note),
              onLongPress: () => onLongPress(note),
            );
          },
          childCount: notes.length,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
      );
    }

    // Non-sliver widget mode
    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (!isGridView) {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: notes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            folder: _getFolderForNote(note),
            onTap: () => onTap(note),
            onLongPress: () => onLongPress(note),
          );
        },
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          folder: _getFolderForNote(note),
          onTap: () => onTap(note),
          onLongPress: () => onLongPress(note),
        );
      },
    );
  }
}
