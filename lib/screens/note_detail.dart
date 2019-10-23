import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:note_keeper/utils/db_helper.dart';
import 'package:note_keeper/models/note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper(); //db

  Note note;
  String appBarTitle;

  TextEditingController titleContoller = TextEditingController();
  TextEditingController descriptionContoller = TextEditingController();

  _NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleContoller.text = note.title;
    descriptionContoller.text = note.description;


    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            onPressed: (){
              moveToLastScreen();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right:10.0),
          child: ListView(
            children: <Widget>[
              //First Element
              ListTile(
                  title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem){
                    return DropdownMenuItem<String> (
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),

                  onChanged: (valueSelectedByUser){
                    setState(() {
                      debugPrint('User Selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),

              //Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: TextField(
                  controller: titleContoller,
                  style: textStyle,
                  onChanged: (value){
                    debugPrint('Title TextField changed');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              //Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: TextField(
                  controller: descriptionContoller,
                  style: textStyle,
                  onChanged: (value){
                    debugPrint('Description TextField changed');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              //Fourth Element
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (){
                          setState(() {
                           debugPrint('Save tapped');
                           _save();
                          });
                        },
                      ),
                    ),

                    Container(width: 5.0,),

                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (){
                          setState(() {
                           debugPrint('Delete tapped'); 
                           _delete();
                          });
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ), 
      onWillPop: () {
        moveToLastScreen();
      },
    );
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  //convert (priority) string into int before saving it into db
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High': 
        note.priority = 1;
        break;
        
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  //convert (priority) int to string and dispaly to user in drop down
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0]; //high
        break;
      case 2:
        priority = _priorities[1]; //low
        break;
    }
    return priority;
  }


  //update titile
  void updateTitle(){
    note.title = titleContoller.text;
  }

  //update description
  void updateDescription(){
    note.description = descriptionContoller.text;
  }

  //save data to db
  void _save() async{

    //after saving navigate to notellist
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now()); //date and time


    int result;
    if(note.id != null){ //update
      result = await helper.updateNote(note);
    }else{
      result = await helper.insertNote(note);
    }

    if(result != 0){ //success
      _showAlertDialog('Status', 'Note Saved Successfully');
    }else{ //failure
      _showAlertDialog('Status', 'Problem in Saving');
    }
  }
  
  void _showAlertDialog(String title, String message){

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }

  // for delete note
  void _delete() async{

    moveToLastScreen();

    //case 1(delete new note ie. FAB)
    if(note.id == null){
      _showAlertDialog('Status', 'No note was Deleted');
      return;
    }
    //case 2 delete existing
    int result = await helper.deleteNote(note.id);

    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted successfully');
    }else{
      _showAlertDialog('Status', 'Error occured while Deleting Note');
    }
  }
}