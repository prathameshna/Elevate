import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate/features/notepad/data/repositories/note_repository_impl.dart';
import 'package:elevate/features/notepad/domain/entities/note_entity.dart';
import 'package:elevate/features/notepad/domain/repositories/note_repository.dart';

// ── Repository ───────────────────────────────────────────────────────────────
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl();
});

// ── Sort Option ──────────────────────────────────────────────────────────────
enum NoteSortOption {
  dateModified,
  dateCreated,
  titleAZ,
  titleZA,
}

extension NoteSortOptionExtension on NoteSortOption {
  String get label {
    switch (this) {
      case NoteSortOption.dateModified:
        return 'Date modified';
      case NoteSortOption.dateCreated:
        return 'Date created';
      case NoteSortOption.titleAZ:
        return 'Title A-Z';
      case NoteSortOption.titleZA:
        return 'Title Z-A';
    }
  }

  NoteSortOption get next {
    final values = NoteSortOption.values;
    return values[(index + 1) % values.length];
  }
}

final noteSortProvider =
    StateProvider<NoteSortOption>((ref) => NoteSortOption.dateModified);

// ── Search Query ─────────────────────────────────────────────────────────────
final noteSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Notes List Notifier ──────────────────────────────────────────────────────
class NotesNotifier extends AsyncNotifier<List<NoteEntity>> {
  @override
  Future<List<NoteEntity>> build() async {
    final repo = ref.read(noteRepositoryProvider);
    final notes = await repo.getNotes();
    return _applyFiltersAndSort(notes);
  }

  List<NoteEntity> _applyFiltersAndSort(List<NoteEntity> notes) {
    final query = ref.watch(noteSearchQueryProvider).toLowerCase();
    final sort = ref.watch(noteSortProvider);

    var filtered = notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (sort) {
        case NoteSortOption.dateModified:
          return b.dateModified.compareTo(a.dateModified);
        case NoteSortOption.dateCreated:
          return b.dateCreated.compareTo(a.dateCreated);
        case NoteSortOption.titleAZ:
          return a.title.compareTo(b.title);
        case NoteSortOption.titleZA:
          return b.title.compareTo(a.title);
      }
    });

    return filtered;
  }

  Future<void> addNote(NoteEntity note) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(note);
    ref.invalidateSelf();
  }

  Future<void> updateNote(NoteEntity note) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.updateNote(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<NoteEntity>>(NotesNotifier.new);
