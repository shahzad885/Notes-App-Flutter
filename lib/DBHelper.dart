import 'dart:io'; // Provides File and Directory classes for accessing file system paths.
import 'package:path/path.dart'; // Provides utilities for working with file and directory paths.
import 'package:path_provider/path_provider.dart'; // Helps in retrieving platform-specific directories for saving files.
import 'package:sqflite/sqflite.dart'; // sqflite package for SQLite database operations.

class Dbhelper {
  Dbhelper._(); // Private constructor to create a singleton class.

  // Singleton instance of Dbhelper.
  static final Dbhelper getInstance = Dbhelper._();

  // Table name and columns
  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no"; // Serial number (Primary Key)
  static const String COLUMN_NOTE_TITLE = "title"; // Title of the note
  static const String COLUMN_NOTE_DESC = "desc"; // Description of the note

  // Database reference
  Database? myDB;

  // Method to retrieve the database instance, opens it if not already open.
  Future<Database?> getDB() async {
    // If database is already open, return it, else open the database.
    if (myDB != null) {
      return myDB;
    } else {
      myDB = await OpenDB();
      return myDB;
    }
  }

  // Method to open the database. Creates the database if it doesn't exist.
  Future<Database> OpenDB() async {
    // Get the application's directory for saving the database file.
    Directory appDirectory = await getApplicationDocumentsDirectory();
    // Join the directory path with the database file name.
    String dbpath = join(appDirectory.path, 'notsDB.db');

    // Open the database and create the table if it's the first time.
    return await openDatabase(dbpath, onCreate: (db, version) {
      // Execute the SQL command to create the 'note' table with columns 's_no', 'title', and 'desc'.
      db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");
    }, version: 1); // Version 1 of the database.
  }

  // Method to add a new note to the database.
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB(); // Get the database instance.

    // Insert the note into the 'note' table with the title and description.
    int rowEffected = await db!.insert(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc});

    // Return true if the insertion was successful, otherwise false.
    return rowEffected > 0;
  }

  // Method to retrieve all notes from the database.
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB(); // Get the database instance.

    // Query the 'note' table to get all the rows (notes).
    List<Map<String, dynamic>> mData = await db!.query(TABLE_NOTE);

    return mData; // Return the list of notes (each note is a map of key-value pairs).
  }

  // Method to update an existing note in the database.
  Future<bool> updateNote(
      {required int sno, required String mTitle, required String mDesc}) async {
    var db = await getDB(); // Get the database instance.

    // Update the 'note' table where 's_no' matches the provided sno.
    int rowEffected = await db!.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mTitle, // Update the title.
          COLUMN_NOTE_DESC: mDesc, // Update the description.
        },
        where:
            "$COLUMN_NOTE_SNO = $sno"); // Only update the note with the matching 's_no'.

    // Return true if the update was successful, otherwise false.
    return rowEffected > 0;
  }

  // Method to delete a note from the database.
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB(); // Get the database instance.

    // Delete the note from the 'note' table where 's_no' matches the provided sno.
    int rowEffected =
        await db!.delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = $sno");

    // Return true if the deletion was successful, otherwise false.
    return rowEffected > 0;
  }
}
