import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/notepad/domain/entities/note_entity.dart';
import 'package:elevate/features/notepad/presentation/providers/notepad_providers.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final NoteEntity? existingNote;

  const NoteDetailPage({super.key, this.existingNote});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  late FocusNode _bodyFocus;

  Timer? _debounce;
  bool _hasUnsavedChanges = false;
  late String _noteId;
  late int _stickingStyleId;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingNote?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existingNote?.body ?? '');
    _bodyFocus = FocusNode();

    if (widget.existingNote == null) {
      // New Note
      _noteId = DateTime.now().millisecondsSinceEpoch.toString();
      _stickingStyleId = Random().nextInt(5) + 1; // 1 to 5
      // Auto-open keyboard for new note
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _bodyFocus.requestFocus();
      });
    } else {
      _noteId = widget.existingNote!.id;
      _stickingStyleId = widget.existingNote!.stickingStyleId;
    }

    _titleCtrl.addListener(_onContentChanged);
    _bodyCtrl.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    _hasUnsavedChanges = true;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    if (!_hasUnsavedChanges) return;
    
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty && body.isEmpty) return; // Don't save empty notes

    final note = NoteEntity(
      id: _noteId,
      title: title.isEmpty ? 'Untitled Note' : title,
      body: body,
      type: widget.existingNote?.type ?? 'default',
      stickingStyleId: _stickingStyleId,
      isUnread: false,
      dateCreated: widget.existingNote?.dateCreated ?? DateTime.now(),
      dateModified: DateTime.now(),
    );

    if (widget.existingNote == null) {
      await ref.read(notesProvider.notifier).addNote(note);
    } else {
      await ref.read(notesProvider.notifier).updateNote(note);
    }
    
    _hasUnsavedChanges = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Final save attempt on exit
    if (_hasUnsavedChanges) {
      _saveNote();
    }
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
        ),
        actions: [
          if (widget.existingNote != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textPrimary),
              onPressed: () async {
                HapticFeedback.selectionClick();
                await ref.read(notesProvider.notifier).deleteNote(_noteId);
                _hasUnsavedChanges = false; // Prevent saving on dispose
                if (context.mounted) {
                  context.pop();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 28,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note title',
                      hintStyle: GoogleFonts.dmSerifDisplay(
                        color: AppTheme.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyCtrl,
                    focusNode: _bodyFocus,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: GoogleFonts.dmSans(
                        color: AppTheme.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
          
          // ── Keyboard Toolbar ───────────────────────────────────────────────
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.cardWhite,
              border: Border(
                top: BorderSide(color: Color(0x14000000), width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_bold_rounded, size: 20),
                  color: AppTheme.textSecondary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic_rounded, size: 20),
                  color: AppTheme.textSecondary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                  color: AppTheme.textSecondary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.checklist_rounded, size: 20),
                  color: AppTheme.textSecondary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.link_rounded, size: 20),
                  color: AppTheme.textSecondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
