import 'package:hive_flutter/hive_flutter.dart';
import 'package:elevate/features/notepad/domain/entities/note_entity.dart';
import 'package:elevate/features/notepad/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  late final Box _box;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _box = Hive.box('notesBox');
    
    if (_box.isEmpty) {
      // Seed initial notes
      final seedNotes = [
        NoteEntity(
          id: '1',
          title: 'Morning Rituals',
          body:
              'Reflections on the morning ritual. Soft light hitting the desk at 6:00 AM. The stillness is where the best ideas are born.',
          type: 'default',
          stickingStyleId: 1,
          isUnread: true,
          dateCreated: DateTime(2023, 10, 12),
          dateModified: DateTime(2023, 10, 12),
        ),
        NoteEntity(
          id: '2',
          title: 'Kitchen Supplies',
          body:
              'Grocery list for the week: Sourdough bread, Organic honey, Espresso beans, Sea salt flakes.',
          type: 'list',
          stickingStyleId: 2,
          isUnread: false,
          dateCreated: DateTime(2023, 10, 11),
          dateModified: DateTime(2023, 10, 11),
        ),
        NoteEntity(
          id: '3',
          title: 'Design Principles',
          body:
              'The new interface should prioritize cognitive ergonomics. Minimalist aesthetic values space and subtle contrasts over aggressive branding elements.',
          type: 'design',
          stickingStyleId: 3,
          isUnread: false,
          dateCreated: DateTime(2023, 10, 10),
          dateModified: DateTime(2023, 10, 10),
        ),
        NoteEntity(
          id: '4',
          title: 'Travel Wishlist',
          body:
              'Ideas for the next escape:\n1. Fjords of Norway\n2. Swiss Alps in Summer\n3. Kyoto Zen Gardens',
          type: 'travel',
          stickingStyleId: 4,
          isUnread: false,
          dateCreated: DateTime(2023, 10, 8),
          dateModified: DateTime(2023, 10, 8),
        ),
        NoteEntity(
          id: '5',
          title: 'Project Sync',
          body:
              'Meeting notes from Thursday: Finalize the layout grid, test typography pairing at 22px titles.',
          type: 'meeting',
          stickingStyleId: 5,
          isUnread: false,
          dateCreated: DateTime(2023, 10, 5),
          dateModified: DateTime(2023, 10, 5),
        ),
        NoteEntity(
          id: '6',
          title: 'Inspiration',
          body: '"The details are not the details. They make the design."\n— Charles Eames',
          type: 'quote',
          stickingStyleId: 1,
          isUnread: false,
          dateCreated: DateTime(2023, 10, 2),
          dateModified: DateTime(2023, 10, 2),
        ),
      ];

      for (final note in seedNotes) {
        await _box.put(note.id, note.toJson());
      }
    }
    _initialized = true;
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    await _init();
    final notes = _box.values.map((e) {
      // Need to cast to Map<dynamic, dynamic> as hive stores map
      return NoteEntity.fromJson(Map<dynamic, dynamic>.from(e as Map));
    }).toList();
    return notes;
  }

  @override
  Future<void> addNote(NoteEntity note) async {
    await _init();
    await _box.put(note.id, note.toJson());
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await _init();
    await _box.put(note.id, note.toJson());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _init();
    await _box.delete(id);
  }
}
