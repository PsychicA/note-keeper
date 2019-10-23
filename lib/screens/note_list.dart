import 'package:flutter/material.dart';
import 'package:note_keeper/screens/note_detail.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:note_keeper/utils/db_helper.dart';
import 'package:note_keeper/models/note.dart';

class NoteList extends StatefulWidget {

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper(); //db
  List<Note> noteList; //display all notes in ui
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if (noteList == null){
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView(){

    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          color: Colors.white,
          elevation: 3.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),

            title: Text(this.noteList[position].title, style: titleStyle,),

            subtitle: Text(this.noteList[position].date),
          
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey,),
              onTap: (){
                _delete(context, noteList[position]);
              },
            ),

            onTap: (){
              debugPrint('ListTile tapped');
              navigateToDetail(this.noteList[position], 'Edit Note');
            },
          ),
        );
      },  
    );
  }

  //priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1: return Colors.red;
              break;

      case 2: return Colors.yellow;
              break;

      default: return Colors.yellow;
    }
  }

  //priority icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1: return Icon(Icons.play_arrow);
              break;

      case 2: return Icon(Icons.keyboard_arrow_right);
              break;

      default: return Icon(Icons.keyboard_arrow_right);
    }
  }

  //delete dbItem
  void _delete(BuildContext context, Note note) async{

    int result = await databaseHelper.deleteNote(note.id); //db
    if (result != 0){
      _showSnackBar(context, 'Note Deleted Successfully');
      
      
      updateListView(); //update ui

    }
  }

  void _showSnackBar(BuildContext context, String message){

    final snackBar = SnackBar(content: Text(message),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(
      builder: (context){
        return NoteDetail(note, title);
      }
    ));

    if (result == true){
      updateListView();
    }
  }


  void updateListView(){
    
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();

      //update UI
      noteListFuture.then((noteList){
        setState(() {
         this.noteList = noteList;
         this.count = noteList.length; 
        });
      });
    });
  }
}