import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _notesCollection =
      _database.collection('notes');

  static Future<void> addNote(String Title, String Description) async {
    //ini method//
    Map<String, dynamic> newNote = {
      'Title': Title,
      "Description": Description,
    };

    await _notesCollection.add(newNote);
  }

  static Future<void> updateNote(
      String id, String Title, String Description) async {
    Map<String, dynamic> updateNote = {
      'Title': Title,
      "Description": Description,
    };
    await _notesCollection.doc(id).update(updateNote);
  }

  static Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  static Future<QuerySnapshot> retrieveNote() {
    return _notesCollection.get();
  }

  static Stream<List<Map<String, dynamic>>> getNoteList() {
    return _notesCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((DocSnapshot) {
        final data = DocSnapshot.data() as Map<String, dynamic>;
        return {'id': DocSnapshot.id, ...data};
      }).toList();
    });
  }
}
