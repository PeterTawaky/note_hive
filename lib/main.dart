import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes_app/Strings.dart';
import 'package:notes_app/edite_note_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //ensure initialization
  await Hive.initFlutter(); //initialize hive
  await Hive.openBox(kMyDb); //create a box
  runApp(NotesApp());
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final notesRef = Hive.box(kMyDb); //take my box in variable to use
  List<Map<String, dynamic>> notesData =
      []; //a list to carry the data in my data base
  List<Map<String, dynamic>> filteredList = [];
  TextEditingController searchFieldController = TextEditingController();

  bool isSearchOpened = false;
  @override
  void initState() {
    getNotes();
    super.initState();
  }

  void addNote({required String title, required String description}) async {
    await notesRef.add(
      {
        //adding a map to the box
        'title': title,
        'description': description,
      },
    );
    getNotes();
  }

  void getNotes() {
    //make loop to save data in my list
    setState(() {
      notesData = notesRef.keys.map((key) {
        final currentNote = notesRef
            .get(key); //current node is a map which i can access it's elements
        return {
          'key': key,
          'title': currentNote['title'],
          'description': currentNote['description'],
        };
      }).toList();
    });
    debugPrint(notesData.length.toString());
  }

  void deleteNote({required int key}) {
    notesRef.delete(key);
    getNotes();
  }

  filterData({required String input}) {
    setState(() {
      filteredList = notesData
          .where((element) => element['title']
              .toString()
              .toLowerCase()
              .startsWith(input.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return MaterialApp(
      title: 'Notes App',
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Colors.black,
        // bottomSheet: ,
        appBar: AppBar(
          titleTextStyle: TextStyle(color: Colors.white),
          title: isSearchOpened
              ? TextField(
                  style: TextStyle(color: Colors.black),
                  controller: searchFieldController,
                  onChanged: (value) {
                    debugPrint(value);
                    filterData(input: value);
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Search'),
                )
              : Text(
                  'Notes App',
                ),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isSearchOpened = !isSearchOpened;
                  if (isSearchOpened == true) {
                    setState(() {
                      filteredList.clear();
                      searchFieldController.clear();
                    });
                  }
                });
              },
              icon: Icon(
                isSearchOpened ? Icons.clear : Icons.search,
                color: Colors.white,
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
              shape: CircleBorder(),
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isDismissible: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsetsDirectional.all(15),
                        child: Column(
                          children: [
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                  hintText: 'title',
                                  border: UnderlineInputBorder()),
                            ),
                            TextField(
                              controller: descriptionController,
                              decoration:
                                  InputDecoration(hintText: 'description'),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: Colors.amber,
                                  child: Text('Add Data'),
                                  onPressed: () {
                                    addNote(
                                        title: titleController.text,
                                        description:
                                            descriptionController.text);
                                    Navigator.pop(context);
                                  }),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ),
        body: notesData.isEmpty
            ? Center(
                child: Text(
                  'Start adding your Notes',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: filteredList.isEmpty
                    ? notesData.length
                    : filteredList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 6, vertical: 2),
                    child: Card(
                      color: Colors.blue.withOpacity(0.5),
                      child: ListTile(
                        title: Text(
                          filteredList.isEmpty
                              ? notesData[index]['title']
                              : filteredList[index]['title'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          filteredList.isEmpty
                              ? notesData[index]['description']
                              : filteredList[index]['description'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        contentPadding: EdgeInsetsDirectional.all(16),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditNoteScreen(
                                          title: notesData[index]['title'],
                                          description: notesData[index]
                                              ['description'],
                                          noteKey: notesData[index]['key']),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    deleteNote(key: notesData[index]['key']);
                                  });
                                },
                                icon: Icon(
                                  Icons.delete,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
