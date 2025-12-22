import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';

/// Service class responsible for exporting and sharing notes in various formats
/// Handles file generation, filename sanitization, and sharing via email or other apps
class ExportService {
  /// Maps language identifiers to file extensions
  /// This is the reverse mapping from note_provider.dart's import feature
  static const Map<String, String> _languageExtensions = {
    'markdown': '.md',
    'javascript': '.js',
    'typescript': '.ts',
    'python': '.py',
    'kotlin': '.kt',
    'java': '.java',
    'go': '.go',
    'rust': '.rs',
    'c': '.c',
    'cpp': '.cpp',
    'swift': '.swift',
    'dart': '.dart',
    'ruby': '.rb',
    'php': '.php',
    'html': '.html',
    'css': '.css',
    'json': '.json',
    'yaml': '.yml',
    'xml': '.xml',
    'sql': '.sql',
    'shell': '.sh',
  };

  /// Returns the appropriate file extension for a given language
  /// Falls back to .txt if the language is not recognized
  String getFileExtension(String language) {
    return _languageExtensions[language.toLowerCase()] ?? '.txt';
  }

  /// Extracts the extension from a filename if present
  /// Returns null if no extension is found
  String? _extractExtension(String filename) {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1 || lastDot == 0 || lastDot == filename.length - 1) {
      return null;
    }
    return filename.substring(lastDot); // includes the dot
  }

  /// Removes the extension from a filename if present
  String _removeExtension(String filename) {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1 || lastDot == 0) {
      return filename;
    }
    return filename.substring(0, lastDot);
  }

  /// Sanitizes a filename by removing special characters and replacing spaces
  /// Ensures the filename is valid across all platforms
  /// Preserves existing file extension if present
  String sanitizeFilename(String title) {
    if (title.trim().isEmpty) {
      return 'Untitled';
    }

    // Extract extension if present
    final extension = _extractExtension(title);
    final nameWithoutExt = extension != null ? _removeExtension(title) : title;

    // Remove or replace special characters that are problematic in filenames
    String sanitized = nameWithoutExt
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // Remove invalid chars
        .replaceAll(RegExp(r'\s+'), '_') // Replace whitespace with underscore
        .trim();

    // Ensure filename is not empty after sanitization
    if (sanitized.isEmpty) {
      return 'Untitled';
    }

    // Limit filename length to 100 characters to avoid path length issues
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    // Add back the extension if it was present
    if (extension != null) {
      sanitized += extension.toLowerCase();
    }

    return sanitized;
  }

  /// Checks if the title already has an extension that conflicts with the expected one
  /// Returns null if no conflict, or a map with 'current' and 'expected' extensions if conflict exists
  Map<String, String>? checkExtensionConflict(String title, String language, String format) {
    final sanitized = sanitizeFilename(title);
    final existingExt = _extractExtension(sanitized);

    if (existingExt == null) {
      return null; // No existing extension, no conflict
    }

    // Determine expected extension based on format
    String expectedExt;
    switch (format) {
      case 'code':
        expectedExt = getFileExtension(language);
        break;
      case 'txt':
        expectedExt = '.txt';
        break;
      case 'md':
        expectedExt = '.md';
        break;
      default:
        expectedExt = '.txt';
    }

    // Check if extensions match (case-insensitive)
    if (existingExt.toLowerCase() == expectedExt.toLowerCase()) {
      return null; // Extensions match, no conflict
    }

    // Conflict detected
    return {
      'current': existingExt,
      'expected': expectedExt,
    };
  }

  /// Generates a complete filename with the appropriate extension
  /// Format options: 'code' (language-specific), 'txt', 'md'
  /// If forceExtension is provided, it overrides the default extension logic
  String generateFilename(String title, String language, String format, {String? forceExtension}) {
    final sanitized = sanitizeFilename(title);
    final existingExt = _extractExtension(sanitized);

    // If forceExtension is provided, use it
    if (forceExtension != null) {
      final nameWithoutExt = existingExt != null ? _removeExtension(sanitized) : sanitized;
      return '$nameWithoutExt$forceExtension';
    }

    // If title already has an extension, check if it matches the expected one
    if (existingExt != null) {
      String expectedExt;
      switch (format) {
        case 'code':
          expectedExt = getFileExtension(language);
          break;
        case 'txt':
          expectedExt = '.txt';
          break;
        case 'md':
          expectedExt = '.md';
          break;
        default:
          expectedExt = '.txt';
      }

      // If extensions match (case-insensitive), use the sanitized name as-is
      if (existingExt.toLowerCase() == expectedExt.toLowerCase()) {
        return sanitized;
      }

      // If they don't match, replace with expected extension
      // (The UI should have already asked the user about this)
      return '${_removeExtension(sanitized)}$expectedExt';
    }

    // No existing extension, add the appropriate one
    switch (format) {
      case 'code':
        return '$sanitized${getFileExtension(language)}';
      case 'txt':
        return '$sanitized.txt';
      case 'md':
        return '$sanitized.md';
      default:
        return '$sanitized.txt';
    }
  }

  /// Creates a plain text file with raw note content
  /// Returns the temporary file path for sharing
  /// If forceExtension is provided, it overrides the default .txt extension
  Future<File> createPlainTextFile(Note note, {String? forceExtension}) async {
    final directory = await getTemporaryDirectory();
    final filename = generateFilename(note.title, note.language, 'txt', forceExtension: forceExtension);
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    // Write raw content as-is
    await file.writeAsString(note.content, flush: true);
    return file;
  }

  /// Creates a markdown file with code wrapped in fenced code blocks
  /// Includes note title as header and language tag for syntax highlighting
  /// If forceExtension is provided, it overrides the default .md extension
  Future<File> createMarkdownFile(Note note, {String? forceExtension}) async {
    final directory = await getTemporaryDirectory();
    final filename = generateFilename(note.title, note.language, 'md', forceExtension: forceExtension);
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    // Build markdown content with title and code block
    final markdownContent = '''# ${note.title}

```${note.language}
${note.content}
```
''';

    await file.writeAsString(markdownContent, flush: true);
    return file;
  }

  /// Creates a code file with language-specific extension
  /// Content is raw note content, filename uses appropriate extension
  /// If forceExtension is provided, it overrides the default language extension
  Future<File> createCodeFile(Note note, {String? forceExtension}) async {
    final directory = await getTemporaryDirectory();
    final filename = generateFilename(note.title, note.language, 'code', forceExtension: forceExtension);
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    // Write raw content for code files
    await file.writeAsString(note.content, flush: true);
    return file;
  }

  /// Shares a file via the system share sheet
  /// The user can then choose Gmail, messaging apps, cloud storage, etc.
  /// This is the recommended approach as it leverages native sharing
  Future<void> shareFile(File file, String subject) async {
    final xFile = XFile(file.path);

    // Share the file with subject as text
    // The share sheet will show all compatible apps (Gmail, Drive, Messages, etc.)
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [xFile],
      subject: subject,
    );
  }

  /// Shares a file specifically targeting email apps
  /// On Android/iOS, this opens the share sheet which the user can use to select Gmail
  /// This is more reliable than mailto: URLs with attachments
  Future<void> shareViaEmail(File file, String subject) async {
    // Use the same shareFile method as it's the most reliable approach
    // The user can select Gmail (or any email app) from the share sheet
    // This avoids platform-specific email intent handling complexities
    await shareFile(file, subject);
  }
}
