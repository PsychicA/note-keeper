import 'package:flutter/widgets.dart';

class Note{
  
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  //mandatory fields
  //description may be optional []
  Note(this._title, this._date, this._priority, [this._description]);

  
  //with id
  Note.withId(this._id, this._title, this._date, this._priority, [this._description]);


  //all getters
  int get id => _id;


  String get title => _title;


  String get description => _description;


  int get priority => _priority;


  String get date => _date;


  //all seters
  //not for id because it will be generated automatically
  set title(String newTitle){
    //validation
    if(newTitle.length<=100){
      this._title = newTitle;
    }
  }

  set description(String newDescription){
    //validation
    if(newDescription.length<=255){
      this._description = newDescription;
    }
  }

  set priority(int newPriority){
    //validation (1 = low, 2 = high)
    if(newPriority>=1 && newPriority<=2){
      this._priority = newPriority;
    }
  }

  set date(String newDate){
    this._date = newDate;
    
  }


  //convert note into map object (helper)
  Map<String, dynamic> toMap(){

    var map = Map<String, dynamic>(); //empty map object

    //insert objects into map
    if(id !=null){
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
  
    return map;
  }

  //Extract note object from map
  Note.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}