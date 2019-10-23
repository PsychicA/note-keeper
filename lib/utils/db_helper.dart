import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper; //singleton dbHelper obj
  static Database _database; //singleton db obj

  //define all columns with table name
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';



  DatabaseHelper._createInstance(); //named constructor to init dbHelper

  factory DatabaseHelper(){

    //create instance of dbHelper only if it is null
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance(); //execute only once, singleton
    }
    return _databaseHelper;
  }

  //Database getter
  Future<Database> get database async{

    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{

    //directory to store db
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //create db at given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }



  void _createDb(Database db, int newVersion) async{
    
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //CRUD operations (insert, update, delete and fetch)
  //fetch: get all note objects from db
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    
    //or
    // var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }
  
  //insert: insert a note in db
  Future<int> insertNote(Note note) async{
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap()); //converting in map then insert
    return result;
  }

  //update: update a note and save it in db
  Future<int> updateNote(Note note) async{
    Database db = await this.database;

    var result = await db.update(noteTable, note.toMap(), where: 'colId = ?', whereArgs: [note.id]); //converting in map then insert
    return result;
  }
  //delete: delete a note from db
  Future<int> deleteNote(int id) async{
    Database db = await this.database;

    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //get no. of obj in db
  Future<int> getCount() async{
    Database db = await this.database;

    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //get 'map list' [List<Map>] and convert it into 'note list' [List<Note>]
  Future<List<Note>> getNoteList() async{
    
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length; //no. of map entries in db

    List<Note> noteList = List<Note>();

    //forloop to create map list to note list
    for (int i=0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}