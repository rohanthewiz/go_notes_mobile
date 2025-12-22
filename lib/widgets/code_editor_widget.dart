import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _lastText = ''; // Track last text to detect actual content changes

  @override
  void initState() {
    super.initState();
    _scrollController = CodeScrollController();

    // Create controller with initial content
    _controller = CodeLineEditingController.fromText(widget.initialValue);
    _lastText = widget.initialValue; // Initialize last text

    // Debug: Listen to focus changes
    _focusNode.addListener(() {
      print('CodeEditor focus changed: ${_focusNode.hasFocus}');
    });

    // Defer listener setup to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to content changes and notify parent only when text actually changes
      // This prevents cursor movements from triggering "unsaved changes"
      _controller.addListener(() {
        final currentText = _controller.text;
        if (currentText != _lastText) {
          _lastText = currentText;
          widget.onChanged?.call(currentText);
        }
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

    // Wrap in Focus with custom onKey handler to add navigation support on Android
    // The re_editor package doesn't support arrow keys on Android by default
    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        print('Focus onKeyEvent: ${event.logicalKey.keyLabel}');

        // Handle navigation keys using the controller's moveCursor method
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.arrowUp) {
          _controller.moveCursor(AxisDirection.up);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowDown) {
          _controller.moveCursor(AxisDirection.down);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          _controller.moveCursor(AxisDirection.left);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          _controller.moveCursor(AxisDirection.right);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.pageUp) {
          _controller.moveCursorToPageUp();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.pageDown) {
          _controller.moveCursorToPageDown();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.home) {
          _controller.moveCursorToLineStart();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.end) {
          _controller.moveCursorToLineEnd();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          print('CodeEditor tapped, requesting focus');
          _focusNode.requestFocus();
        },
        behavior: HitTestBehavior.opaque,
        child: CodeEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        readOnly: widget.readOnly,
        autofocus: !widget.readOnly,
        wordWrap: true,
        // Explicitly provide shortcuts activators
        shortcutsActivatorsBuilder: const DefaultCodeShortcutsActivatorsBuilder(),
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
        ),
      ),
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
