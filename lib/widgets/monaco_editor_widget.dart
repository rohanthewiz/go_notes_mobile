import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';

/// Wrapper widget for MonacoEditor that provides a simpler API
/// This widget manages the MonacoController lifecycle and provides
/// a straightforward interface for code editing
class MonacoEditorWidget extends StatefulWidget {
  final String initialValue;
  final String language;
  final bool readOnly;
  final String theme;
  final ValueChanged<String>? onChanged;

  const MonacoEditorWidget({
    super.key,
    this.initialValue = '',
    this.language = 'markdown',
    this.readOnly = false,
    this.theme = 'vs-dark',
    this.onChanged,
  });

  @override
  State<MonacoEditorWidget> createState() => _MonacoEditorWidgetState();
}

class _MonacoEditorWidgetState extends State<MonacoEditorWidget> {
  MonacoController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Initialize the Monaco editor controller with the specified options
  /// Configures the editor for optimal mobile touch and focus behavior
  Future<void> _initializeController() async {
    try {
      // Convert language string to MonacoLanguage enum
      final monacoLanguage = _getMonacoLanguage(widget.language);

      // Convert theme string to MonacoTheme enum
      final monacoTheme = _getMonacoTheme(widget.theme);

      // Create controller with options optimized for mobile
      // Additional options to ensure proper rendering on every keystroke
      final controller = await MonacoController.create(
        options: EditorOptions(
          language: monacoLanguage,
          theme: monacoTheme,
          readOnly: widget.readOnly,
          fontSize: 14,
          wordWrap: true,
          minimap: false,
          lineNumbers: true,
          // Mobile-specific options for better touch handling and rendering
          automaticLayout: true,  // Automatically resize editor
          scrollBeyondLastLine: false,
          smoothScrolling: false,  // Disable smooth scrolling for immediate updates
          disableLayerHinting: true,  // Force immediate rendering without layer optimization
          quickSuggestions: false,  // Disable autocomplete suggestions
        ),
      );

      // Set initial value if provided
      if (widget.initialValue.isNotEmpty) {
        await controller.setValue(widget.initialValue);
      }

      // Listen to content changes
      controller.onContentChanged.listen((_) async {
        // Get the current content from the editor
        final content = await controller.getValue();
        widget.onChanged?.call(content);
      });

      if (mounted) {
        setState(() {
          _controller = controller;
          _isReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing Monaco editor: $e');
    }
  }

  /// Convert language string to MonacoLanguage enum
  /// Provides mapping for common languages used in GoNotes
  MonacoLanguage _getMonacoLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'javascript':
        return MonacoLanguage.javascript;
      case 'typescript':
        return MonacoLanguage.typescript;
      case 'python':
        return MonacoLanguage.python;
      case 'java':
        return MonacoLanguage.java;
      case 'go':
        return MonacoLanguage.go;
      case 'rust':
        return MonacoLanguage.rust;
      case 'c':
        return MonacoLanguage.c;
      case 'cpp':
      case 'c++':
        return MonacoLanguage.cpp;
      case 'swift':
        return MonacoLanguage.swift;
      case 'dart':
        return MonacoLanguage.dart;
      case 'ruby':
        return MonacoLanguage.ruby;
      case 'php':
        return MonacoLanguage.php;
      case 'html':
        return MonacoLanguage.html;
      case 'css':
        return MonacoLanguage.css;
      case 'json':
        return MonacoLanguage.json;
      case 'yaml':
        return MonacoLanguage.yaml;
      case 'xml':
        return MonacoLanguage.xml;
      case 'sql':
        return MonacoLanguage.sql;
      case 'shell':
      case 'bash':
        return MonacoLanguage.shell;
      case 'markdown':
      default:
        return MonacoLanguage.markdown;
    }
  }

  /// Convert theme string to MonacoTheme enum
  MonacoTheme _getMonacoTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'vs':
      case 'light':
        return MonacoTheme.vs;
      case 'vs-dark':
      case 'dark':
        return MonacoTheme.vsDark;
      case 'hc-black':
        return MonacoTheme.hcBlack;
      case 'hc-light':
        return MonacoTheme.hcLight;
      default:
        return MonacoTheme.vsDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Use Listener to detect taps without interfering with Monaco's touch handling
    // Listener passes events through, unlike GestureDetector which consumes them
    return Listener(
      onPointerDown: (_) {
        // Request focus when editor is tapped to show keyboard
        // This doesn't interfere with Monaco's internal cursor positioning
        _controller?.focus();
      },
      child: const MonacoEditor(
        showStatusBar: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
