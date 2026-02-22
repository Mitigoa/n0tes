import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/folder_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/note_grid.dart';

import 'note_editor_screen.dart';
import 'folder_management_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<NoteProvider>().setSearchQuery(query);
  }

  void _navigateToSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _navigateToFolders() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const FolderManagementScreen()));
  }

  void _createNewNote() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const NoteEditorScreen()));
  }

  void _editNote(note) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
  }

  void _showNoteModal(note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                  note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                context.read<NoteProvider>().togglePin(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(note.isArchived ? Icons.unarchive : Icons.archive),
              title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () {
                context.read<NoteProvider>().toggleArchive(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<NoteProvider>().deleteNote(note.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final folderProvider = context.watch<FolderProvider>();

    final pinnedNotes = noteProvider.pinnedNotes;
    final unpinnedNotes = noteProvider.unpinnedNotes;
    // Debug: log counts (prefixed with app name)
    print(
        'Quicknotes: HomeScreen.build: total=${noteProvider.notes.length} pinned=${pinnedNotes.length} unpinned=${unpinnedNotes.length}');
    final isSearching = _isSearching || _searchController.text.isNotEmpty;
    final displayNotes = isSearching ? noteProvider.notes : unpinnedNotes;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isSearching ? '' : 'Quicknotes',
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _onSearchChanged('');
                  });
                },
              )
            : null,
        centerTitle: false,
        actions: [
          if (_isSearching)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 48, right: 8, top: 4, bottom: 4),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.5)),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(
                  _isGridView ? Icons.view_agenda_outlined : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'folders') {
                  _navigateToFolders();
                } else if (value == 'settings') {
                  _navigateToSettings();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'folders',
                    child: Text('Folders'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ];
              },
            ),
          ]
        ],
      ),
      body: noteProvider.isLoading || folderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await noteProvider.loadNotes();
                await folderProvider.loadFolders();
              },
              child: CustomScrollView(
                slivers: [
                  if (!isSearching && pinnedNotes.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                        child: Text(
                          'PINNED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    NoteGrid(
                      notes: pinnedNotes,
                      folders: folderProvider.folders,
                      isGridView: _isGridView,
                      onTap: _editNote,
                      onLongPress: _showNoteModal,
                      asSliver: true,
                    ),
                  ],
                  if (!isSearching &&
                      pinnedNotes.isNotEmpty &&
                      displayNotes.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                        child: Text(
                          'OTHERS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  NoteGrid(
                    notes: displayNotes,
                    folders: folderProvider.folders,
                    isGridView: _isGridView,
                    onTap: _editNote,
                    onLongPress: _showNoteModal,
                    asSliver: true,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
