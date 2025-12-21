import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

/// Wrapper widget for ReEditor that provides a simpler API
/// This widget manages the CodeLineEditingController and provides
/// a straightforward interface for code editing with syntax highlighting
class CodeEditorWidget extends StatefulWidget {
  final String initialValue;
  final String language;
  final bool readOnly;
  final String theme;
  final ValueChanged<String>? onChanged;

  const CodeEditorWidget({
    super.key,
    this.initialValue = '',
    this.language = 'markdown',
    this.readOnly = false,
    this.theme = 'vs-dark',
    this.onChanged,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeLineEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late CodeScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = CodeScrollController();

    // Create controller with initial content
    _controller = CodeLineEditingController.fromText(widget.initialValue);

    // Defer listener setup to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to content changes and notify parent
      _controller.addListener(() {
        widget.onChanged?.call(_controller.text);
      });
    });
  }

  @override
  void didUpdateWidget(CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if theme or language changed
    if (oldWidget.theme != widget.theme || oldWidget.language != widget.language) {
      setState(() {});
    }
  }

  /// Get the language mode for syntax highlighting
  dynamic _getLanguageMode(String lang) {
    switch (lang.toLowerCase()) {
      case 'javascript':
      case 'js':
        return langJavascript;
      case 'typescript':
      case 'ts':
        return langTypescript;
      case 'python':
      case 'py':
        return langPython;
      case 'java':
        return langJava;
      case 'go':
        return langGo;
      case 'dart':
        return langDart;
      case 'json':
        return langJson;
      case 'yaml':
      case 'yml':
        return langYaml;
      case 'xml':
        return langXml;
      case 'sql':
        return langSql;
      case 'shell':
      case 'bash':
      case 'sh':
        return langBash;
      case 'markdown':
      case 'md':
      default:
        return langMarkdown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.contains('dark') || widget.theme.contains('hc-black');

    // Get syntax highlighting theme
    final highlightTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;

    // Get language mode for current language
    final languageMode = _getLanguageMode(widget.language);

    return CodeEditor(
      controller: _controller,
      focusNode: _focusNode,
      scrollController: _scrollController,
      readOnly: widget.readOnly,
      wordWrap: true,
      style: CodeEditorStyle(
        // Syntax highlighting with language
        codeTheme: CodeHighlightTheme(
          languages: {
            widget.language: CodeHighlightThemeMode(mode: languageMode),
          },
          theme: highlightTheme,
        ),

        // Text style
        fontSize: 14.0,
        fontFamily: 'monospace',

        // Cursor and selection colors
        cursorColor: isDark ? const Color(0xFFAEAFAD) : const Color(0xFF000000),
        selectionColor: isDark ? const Color(0xFF264F78) : const Color(0xFFADD6FF),
      ),
      indicatorBuilder: (context, editingController, chunkController, notifier) {
        // Line numbers on the left
        return Row(
          children: [
            DefaultCodeLineNumber(
              controller: editingController,
              notifier: notifier,
            ),
            DefaultCodeChunkIndicator(
              width: 20,
              controller: chunkController,
              notifier: notifier,
            ),
          ],
        );
      },
      // Enable code folding
      chunkAnalyzer: DefaultCodeChunkAnalyzer(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
