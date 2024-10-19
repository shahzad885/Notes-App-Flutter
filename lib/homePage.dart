import 'package:flutter/material.dart';
import 'package:notes/DBHelper.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];

  Dbhelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = Dbhelper.getInstance;
    getNotes();
  }

  // Fetch notes from the database
  void getNotes() async {
    final notes = await dbRef!.getAllNotes();
    setState(() {
      allNotes = notes;
    });
  }

  // Function to delete a note by index
  void deleteNoteByIndex(int index) async {
    int sno = allNotes[index]['s_no']; // Get the s_no from the selected note
    bool success = await dbRef!.deleteNote(sno: sno); // Delete the note from DB
    if (success) {
      getNotes(); // Refresh the list after deletion
    }
  }

  // Function to update a note by index
  void updateNoteByIndex(int index) {
    titleController.text = allNotes[index]['title']; // Set the current title
    descController.text =
        allNotes[index]['desc']; // Set the current description

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Note',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title here',
                  label: const Text('Title'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter Description here',
                  label: const Text('Description'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () async {
                        var title = titleController.text;
                        var desc = descController.text;
                        if (title.isNotEmpty && desc.isNotEmpty) {
                          int sno =
                              allNotes[index]['s_no']; // Get s_no of the note
                          bool check = await dbRef!
                              .updateNote(sno: sno, mTitle: title, mDesc: desc);
                          if (check) {
                            getNotes(); // Refresh the list after update
                            titleController.clear();
                            descController.clear();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Update Note'),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length, // Use the length of the list
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text((index + 1)
                      .toString()), // Display the index (starting from 1)
                  title: Text(allNotes[index]['title'] ?? ''),
                  subtitle: Text(allNotes[index]['desc'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),

                        onPressed: () =>
                            updateNoteByIndex(index), // Edit note by index
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () =>
                            deleteNoteByIndex(index), // Delete note by index
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text('No Notes Yet!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Note',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter title here',
                        label: const Text('Title'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter Description here',
                        label: const Text('Description'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            onPressed: () async {
                              var title = titleController.text;
                              var desc = descController.text;
                              if (title.isNotEmpty && desc.isNotEmpty) {
                                bool check = await dbRef!
                                    .addNote(mTitle: title, mDesc: desc);
                                if (check) {
                                  getNotes(); // Refresh the list after adding a note
                                  titleController.clear();
                                  descController.clear();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please fill all fields')),
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Add Note'),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
