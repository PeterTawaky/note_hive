import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/Strings.dart';
import 'package:notes_app/main.dart';

class EditNoteScreen extends StatelessWidget {
  final String title;
  final String description;
  final int noteKey;
  final notesRef = Hive.box(kMyDb); //take my box in variable to use

  EditNoteScreen({
    super.key,
    required this.title,
    required this.description,
    required this.noteKey,
  });
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  updateNote() {
    notesRef.put(noteKey, {
      'title': titleController.text,
      'description': descriptionController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = title;
    descriptionController.text = description;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Edit Notes'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        padding: EdgeInsetsDirectional.all(15),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  hintText: 'title', border: UnderlineInputBorder()),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'description'),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: MaterialButton(
                  color: Colors.amber,
                  child: Text('Edit Data'),
                  onPressed: () {
                    if (title != titleController.text ||
                        description != descriptionController.text) {
                      //there is a change happened

                      updateNote();
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => NotesApp()));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
