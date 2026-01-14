import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_provider.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/language_selector.dart';
import '../widgets/share_bottom_sheet.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;

  const NoteEditorScreen({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  Note? _note;
  String _currentContent = '';
  String _currentLanguage = 'markdown';
  String _currentTheme = 'vs-dark';
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;
  bool _autoSaveEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNote();

    // Register hardware keyboard listener for Ctrl+S
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Debug: Log all key events
    if (event is KeyDownEvent) {
      print('HardwareKeyboard: ${event.logicalKey.keyLabel}');

      // Handle Ctrl+S for save
      if (event.logicalKey == LogicalKeyboardKey.keyS &&
          HardwareKeyboard.instance.isControlPressed) {
        print('Ctrl+S detected, saving...');
        _saveNote();
        return true; // Consume the event
      }
    }
    return false; // Let other keys pass through
  }

  Future<void> _loadNote() async {
    final provider = context.read<NoteProvider>();
    final note = await provider.getNoteById(widget.noteId);

    if (note != null) {
      setState(() {
        _note = note;
        _titleController.text = note.title;
        _currentContent = note.body;
        _currentLanguage = note.language;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveNote() async {
    if (_note == null) return;

    final provider = context.read<NoteProvider>();
    final updatedNote = _note!.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled Note'
          : _titleController.text.trim(),
      body: _currentContent,
      language: _currentLanguage,
    );

    await provider.updateNote(updatedNote);
    setState(() {
      _note = updatedNote;
      _hasUnsavedChanges = false;
    });
  }

  void _onContentChanged(String content) {
    setState(() {
      _currentContent = content;
      _hasUnsavedChanges = true;
    });

    if (_autoSaveEnabled) {
      _debounceAutoSave();
    }
  }

  // Auto-save debouncing
  DateTime? _lastAutoSave;
  Future<void> _debounceAutoSave() async {
    await Future.delayed(const Duration(seconds: 7));
    final now = DateTime.now();

    if (_lastAutoSave == null ||
        now.difference(_lastAutoSave!) > const Duration(seconds: 7)) {
      _lastAutoSave = now;
      if (_hasUnsavedChanges) {
        await _saveNote();
      }
    }
  }

  void _showShareBottomSheet() {
    if (_note == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ShareBottomSheet(note: _note!),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: LanguageSelector.languages.map((lang) {
          final isSelected = lang['id'] == _currentLanguage;
          return ListTile(
            leading: Icon(
              LanguageSelector.getLanguageIcon(lang['id']!),
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
            title: Text(
              lang['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                _currentLanguage = lang['id']!;
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showThemeSelector() {
    final themes = [
      {'id': 'vs-dark', 'name': 'Dark (VS Code)'},
      {'id': 'vs-light', 'name': 'Light (VS Code)'},
      {'id': 'hc-black', 'name': 'High Contrast Dark'},
      {'id': 'hc-light', 'name': 'High Contrast Light'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            final isSelected = theme['id'] == _currentTheme;
            return RadioListTile<String>(
              title: Text(theme['name']!),
              value: theme['id']!,
              groupValue: _currentTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentTheme = value;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your changes before leaving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Don't Save", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                await _saveNote();
                if (mounted) Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // No Shortcuts wrapper - Ctrl+S handled via HardwareKeyboard listener
    // This ensures navigation keys can reach the CodeEditor without interference
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: const InputDecoration(
              hintText: 'Note title...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white60),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          actions: [
            if (_hasUnsavedChanges && !_autoSaveEnabled)
              Focus(
                canRequestFocus: false,
                child: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveNote,
                  tooltip: 'Save',
                ),
              ),
            Focus(
              canRequestFocus: false,
              child: IconButton(
                icon: const Icon(Icons.palette),
                onPressed: _showThemeSelector,
                tooltip: 'Change Theme',
              ),
            ),
            Focus(
              canRequestFocus: false,
              child: IconButton(
                icon: const Icon(Icons.code),
                onPressed: _showLanguageSelector,
                tooltip: 'Change Language',
              ),
            ),
            Focus(
              canRequestFocus: false,
              child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _showShareBottomSheet();
                    break;
                  case 'auto_save':
                    setState(() {
                      _autoSaveEnabled = !_autoSaveEnabled;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _autoSaveEnabled
                              ? 'Auto-save enabled'
                              : 'Auto-save disabled',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'auto_save',
                  child: Row(
                    children: [
                      Icon(_autoSaveEnabled ? Icons.toggle_on : Icons.toggle_off),
                      const SizedBox(width: 8),
                      Text(_autoSaveEnabled ? 'Disable Auto-save' : 'Enable Auto-save'),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Language indicator bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    LanguageSelector.getLanguageIcon(_currentLanguage),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LanguageSelector.getLanguageName(_currentLanguage),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_autoSaveEnabled && !_hasUnsavedChanges)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ),
                  if (_hasUnsavedChanges)
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        const Text(
                          'Unsaved changes',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Code Editor - no shortcuts wrapper, CodeEditor handles its own keyboard input
            Expanded(
              child: CodeEditorWidget(
                initialValue: _currentContent,
                language: _currentLanguage,
                theme: _currentTheme,
                onChanged: _onContentChanged,
              ),
            ),
          ],
        ),
        // Keyboard shortcuts info
        bottomNavigationBar: _buildKeyboardShortcutsBar(),
        // Floating action button for manual save (especially useful on mobile)
        floatingActionButton: _hasUnsavedChanges && !_autoSaveEnabled
            ? FloatingActionButton(
                onPressed: _saveNote,
                tooltip: 'Save note',
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }

  Widget _buildKeyboardShortcutsBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildShortcutChip('Ctrl+S', 'Save'),
            _buildShortcutChip('Ctrl+F', 'Find'),
            _buildShortcutChip('Ctrl+H', 'Replace'),
            _buildShortcutChip('Ctrl+Z', 'Undo'),
            _buildShortcutChip('Ctrl+Y', 'Redo'),
            _buildShortcutChip('Ctrl+/', 'Comment'),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(String shortcut, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        label: Text(
          '$shortcut: $action',
          style: const TextStyle(fontSize: 10),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
