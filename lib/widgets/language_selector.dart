import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  static const List<Map<String, String>> languages = [
    {'id': 'markdown', 'name': 'Markdown'},
    {'id': 'javascript', 'name': 'JavaScript'},
    {'id': 'typescript', 'name': 'TypeScript'},
    {'id': 'python', 'name': 'Python'},
    {'id': 'kotlin', 'name': 'Kotlin'},
    {'id': 'java', 'name': 'Java'},
    {'id': 'go', 'name': 'Go'},
    {'id': 'rust', 'name': 'Rust'},
    {'id': 'c', 'name': 'C'},
    {'id': 'cpp', 'name': 'C++'},
    {'id': 'swift', 'name': 'Swift'},
    {'id': 'dart', 'name': 'Dart'},
    {'id': 'ruby', 'name': 'Ruby'},
    {'id': 'php', 'name': 'PHP'},
    {'id': 'html', 'name': 'HTML'},
    {'id': 'css', 'name': 'CSS'},
    {'id': 'json', 'name': 'JSON'},
    {'id': 'yaml', 'name': 'YAML'},
    {'id': 'xml', 'name': 'XML'},
    {'id': 'sql', 'name': 'SQL'},
    {'id': 'shell', 'name': 'Shell/Bash'},
    {'id': 'plaintext', 'name': 'Plain Text'},
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedLanguage,
      icon: const Icon(Icons.code),
      tooltip: 'Select Language',
      onSelected: onLanguageChanged,
      itemBuilder: (BuildContext context) {
        return languages.map((lang) {
          return PopupMenuItem<String>(
            value: lang['id'],
            child: Row(
              children: [
                if (lang['id'] == selectedLanguage)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Text(lang['name']!),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  static String getLanguageName(String languageId) {
    final lang = languages.firstWhere(
      (l) => l['id'] == languageId,
      orElse: () => {'id': languageId, 'name': languageId},
    );
    return lang['name']!;
  }

  static IconData getLanguageIcon(String languageId) {
    const iconMap = {
      'markdown': Icons.notes,
      'javascript': Icons.javascript,
      'typescript': Icons.code,
      'python': Icons.code,
      'java': Icons.coffee,
      'kotlin': Icons.android,
      'dart': Icons.flutter_dash,
      'html': Icons.html,
      'css': Icons.style,
      'json': Icons.data_object,
      'yaml': Icons.settings,
      'sql': Icons.storage,
      'shell': Icons.terminal,
    };

    return iconMap[languageId] ?? Icons.description;
  }
}
