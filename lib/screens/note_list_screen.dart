import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add'),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Title : ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _titleController,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Description : ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); //Pop untuk menutup
                        },
                        child: const Text('Cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> newNote = {};
                      newNote['Title'] = _titleController.text;
                      newNote['Description'] = _descriptionController.text;

                      FirebaseFirestore.instance
                          .collection('notes')
                          .add(newNote)
                          .whenComplete(
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'All Notes',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error : ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: snapshot.data!.docs.map((document) {
                return Card(
                    child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController titleController =
                            TextEditingController(text: document['Title']);
                        TextEditingController descriptionController =
                            TextEditingController(
                                text: document['Description']);
                        return AlertDialog(
                          title: const Text(
                            'Update Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  25, // Sesuaikan dengan ukuran yang Anda inginkan
                            ),
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Title : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      18, // Sesuaikan dengan ukuran yang Anda inginkan
                                ),
                                textAlign: TextAlign.start,
                              ),
                              TextField(
                                controller: titleController,
                                // decoration: InputDecoration(
                                //   hintText: document['Title'],
                                // ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Description : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        18, // Sesuaikan dengan ukuran yang Anda inginkan
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              TextField(
                                controller: descriptionController,
                                // decoration: InputDecoration(
                                //   hintText: document['Description'],
                                // ),
                              ),
                            ],
                          ),
                          actions: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); //Pop untuk menutup
                                  },
                                  child: const Text('Cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Map<String, dynamic> updateNote = {};
                                updateNote['Title'] = titleController.text;
                                updateNote['Description'] =
                                    descriptionController.text;

                                FirebaseFirestore.instance
                                    .collection('notes')
                                    .doc(document.id)
                                    .update(updateNote)
                                    .whenComplete(
                                  () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  title: Text(document['Title']),
                  subtitle: Text(document['Description']),
                  trailing: InkWell(
                    onTap: () {
                      _showDeleteConfirmationDialog(context, document.id);
                      FirebaseFirestore.instance
                          .collection('notes')
                          .doc(document.id)
                          .delete()
                          .catchError((e) {
                        print(e);
                      });
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Icon(Icons.delete),
                    ),
                  ),
                ));
              }).toList(),
            );
        }
      },
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus item ini ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(documentId);
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
          ],
        );
      });
}

void _deleteItem(String documentId) {
  FirebaseFirestore.instance
      .collection('notes')
      .doc(documentId)
      .delete()
      .catchError((e) {
    print(e);
  });
}
