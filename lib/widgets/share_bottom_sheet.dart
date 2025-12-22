import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/export_service.dart';

/// Bottom sheet widget that provides sharing and export options for notes
/// Offers three primary actions: Email (Gmail), Export as file, and Share to apps
class ShareBottomSheet extends StatelessWidget {
  final Note note;
  final ExportService _exportService = ExportService();

  ShareBottomSheet({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    // Get the file extension for display purposes
    final extension = _exportService.getFileExtension(note.language);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Share Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Option 1: Email (Gmail)
          _buildShareOption(
            context: context,
            icon: Icons.email,
            iconColor: Colors.red,
            title: 'Email (Gmail)',
            subtitle: 'Send as $extension file attachment',
            onTap: () => _handleEmailShare(context),
          ),

          const Divider(height: 1),

          // Option 2: Export as File
          _buildShareOption(
            context: context,
            icon: Icons.file_download,
            iconColor: Colors.blue,
            title: 'Export as file',
            subtitle: 'Choose format (txt, md, $extension)',
            onTap: () => _showFormatPicker(context),
          ),

          const Divider(height: 1),

          // Option 3: Share to Apps
          _buildShareOption(
            context: context,
            icon: Icons.share,
            iconColor: Colors.green,
            title: 'Share to other apps',
            subtitle: 'Share via messaging, cloud, etc.',
            onTap: () => _handleShareToApps(context),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds a single share option tile with icon, title, subtitle, and tap handler
  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Handles email sharing - creates code file and opens share sheet
  /// User can select Gmail from the share sheet
  Future<void> _handleEmailShare(BuildContext context) async {
    try {
      Navigator.pop(context); // Close bottom sheet

      // Check for extension conflict
      final conflict = _exportService.checkExtensionConflict(note.title, note.language, 'code');
      String? forceExtension;

      if (conflict != null && context.mounted) {
        final choice = await _showExtensionConflictDialog(
          context,
          conflict['current']!,
          conflict['expected']!,
        );

        if (choice == null) {
          return; // User cancelled
        }
        forceExtension = choice;
      }

      if (context.mounted) {
        _showLoadingSnackBar(context, 'Preparing file...');
      }

      // Create code file with language-specific extension
      final file = await _exportService.createCodeFile(note, forceExtension: forceExtension);

      // Share via email (opens share sheet where user can select Gmail)
      await _exportService.shareViaEmail(file, note.title);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to share via email: $e');
      }
    }
  }

  /// Shows format picker dialog for export option
  /// Allows user to choose between plain text, markdown, or code file
  Future<void> _showFormatPicker(BuildContext context) async {
    final format = await showDialog<String>(
      context: context,
      builder: (context) => _FormatPickerDialog(
        note: note,
        exportService: _exportService,
      ),
    );

    if (format != null && context.mounted) {
      Navigator.pop(context); // Close bottom sheet
      await _handleExportWithFormat(context, format);
    }
  }

  /// Exports and shares file in the selected format
  Future<void> _handleExportWithFormat(BuildContext context, String format) async {
    try {
      // Check for extension conflict
      final conflict = _exportService.checkExtensionConflict(note.title, note.language, format);
      String? forceExtension;

      if (conflict != null && context.mounted) {
        final choice = await _showExtensionConflictDialog(
          context,
          conflict['current']!,
          conflict['expected']!,
        );

        if (choice == null) {
          return; // User cancelled
        }
        forceExtension = choice;
      }

      if (context.mounted) {
        _showLoadingSnackBar(context, 'Creating file...');
      }

      File file;
      switch (format) {
        case 'txt':
          file = await _exportService.createPlainTextFile(note, forceExtension: forceExtension);
          break;
        case 'md':
          file = await _exportService.createMarkdownFile(note, forceExtension: forceExtension);
          break;
        case 'code':
          file = await _exportService.createCodeFile(note, forceExtension: forceExtension);
          break;
        default:
          throw Exception('Unknown format: $format');
      }

      await _exportService.shareFile(file, note.title);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to export file: $e');
      }
    }
  }

  /// Handles sharing to other apps - creates code file and opens share sheet
  Future<void> _handleShareToApps(BuildContext context) async {
    try {
      Navigator.pop(context); // Close bottom sheet

      // Check for extension conflict
      final conflict = _exportService.checkExtensionConflict(note.title, note.language, 'code');
      String? forceExtension;

      if (conflict != null && context.mounted) {
        final choice = await _showExtensionConflictDialog(
          context,
          conflict['current']!,
          conflict['expected']!,
        );

        if (choice == null) {
          return; // User cancelled
        }
        forceExtension = choice;
      }

      if (context.mounted) {
        _showLoadingSnackBar(context, 'Preparing file...');
      }

      // Create code file with language-specific extension
      final file = await _exportService.createCodeFile(note, forceExtension: forceExtension);

      // Share file via system share sheet
      await _exportService.shareFile(file, note.title);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to share file: $e');
      }
    }
  }

  /// Shows a dialog asking the user which file extension to use
  Future<String?> _showExtensionConflictDialog(
    BuildContext context,
    String currentExt,
    String expectedExt,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Extension Conflict'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The note title already has an extension ($currentExt), but the expected extension for this format is $expectedExt.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Which extension would you like to use?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, currentExt),
            child: Text('Use $currentExt (from title)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, expectedExt),
            child: Text('Use $expectedExt (standard)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Shows a loading snackbar with a message
  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  /// Shows an error snackbar with a message
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Dialog widget for selecting export format
/// Provides radio button options for plain text, markdown, and code file formats
class _FormatPickerDialog extends StatefulWidget {
  final Note note;
  final ExportService exportService;

  const _FormatPickerDialog({
    required this.note,
    required this.exportService,
  });

  @override
  State<_FormatPickerDialog> createState() => _FormatPickerDialogState();
}

class _FormatPickerDialogState extends State<_FormatPickerDialog> {
  String _selectedFormat = 'code';

  @override
  Widget build(BuildContext context) {
    final extension = widget.exportService.getFileExtension(widget.note.language);

    return AlertDialog(
      title: const Text('Choose Export Format'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Plain text (.txt)'),
            subtitle: const Text('Raw content without formatting'),
            value: 'txt',
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Markdown (.md)'),
            subtitle: const Text('Wrapped in code block with language tag'),
            value: 'md',
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Code file ($extension)'),
            subtitle: Text('Language-specific extension for ${widget.note.language}'),
            value: 'code',
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedFormat),
          child: const Text('Export'),
        ),
      ],
    );
  }
}
