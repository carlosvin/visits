
import 'dart:html';
import 'dart:async';
import 'visits_db.dart';

void main() {

  if (DB.isSupported()){
    DB db = new DB();
    VisitList visitList = new VisitList();
    Saver saver = new Saver(db, visitList);
    db.open().whenComplete(
        visitList.drawList(db.visits));
    
    VisitFormView visitForm = new VisitFormView(saver);
  }else{
    var p = querySelector("#main_msg");
      p..text = 'Necesitas un navegador más moderno'
       ..classes.add('error'); 
  }
}

class VisitList extends SaverListener{
  
  TableElement _table;
  
  VisitList(){
    _table = querySelector("#visits_table");
  }
  
  drawList (List<Visit> visits){
    for (Visit v in visits){
      added(v);
    }
  }
  
  added(Visit visit){
    new VisitRowView(visit, _table.addRow());
  }

}

abstract class SaverListener {
  added(Visit visit);
}

class Saver {
  
  DB _db;
  SaverListener _listener;
  
  Saver(DB db, SaverListener listener){
    _db = db;
    _listener = listener;
  }
  
  void add(Visit visit){
    _db.add(visit).whenComplete(_listener.added(visit));
  }
  
}

class VisitFormView{
  
  Visit _visit;
  Saver _saver;
  
  //DB db;
  DateInputElement dateInput;
  NumberInputElement boysInput, girslInput, menInput, womenInput;
  ButtonElement button;
  Element form;
  
  VisitFormView(Saver saver){
    _visit = new Visit();
    _saver = saver;
    dateInput = new DateInputElement();
    boysInput = new NumberInputElement();
    girslInput = new NumberInputElement();
    menInput = new NumberInputElement();
    womenInput = new NumberInputElement();
    button = new ButtonElement();
    button..id = 'save'
          ..text = 'Salvar'
          ..classes.add('important')
          ..onClick.listen((e) => save());
    
    form = querySelector("#input_visits");
    form.append(dateInput);
    form.append(boysInput);
    form.append(girslInput);
    form.append(menInput);
    form.append(womenInput);
    form.append(button);
    
    loadToFrom(_visit);
  }
  
  Visit loadFromForm(){
    _visit.boys = boysInput.valueAsNumber;
    _visit.girls = girslInput.valueAsNumber;
    _visit.men = menInput.valueAsNumber;
    _visit.women = womenInput.valueAsNumber;
    _visit.date = dateInput.valueAsDate;
    return _visit;
  }
  
  void loadToFrom(Visit visit){
    boysInput.valueAsNumber = visit.boys;
    girslInput.valueAsNumber = visit.girls;
    womenInput.valueAsNumber = visit.women;
    menInput.valueAsNumber = visit.men;
    dateInput.valueAsDate = visit.date;
  }
  
  save(){
    loadFromForm();
    _saver.add(_visit);
  }
}

class Visit{

  //var id;
  DateTime date;
  var boys, girls, men, women;
  
  Visit(){
    date = new DateTime.now();
    boys = 0;
    girls = 0;
    men = 0;
    women = 0;
  }
  
  Visit.fromRaw(Map value):
    date = DateTime.parse(value['date']),
    boys = value['boys'],
    girls = value['girls'],
    men = value['men'],
    women = value['women'];
  
  
  Map toRaw() {
    return {
      'date': date.toString(),
      'boys': boys,
      'girls': girls,
      'men': men,
      'women': women,
    };
  }
  
  String getKey(){
    return date.toString();
  }
}


class VisitRowView {
  VisitRowView(Visit visit, TableRowElement row){
    row.addCell().text = visit.date.toLocal().toString();
    row.addCell().text = visit.girls.toString();
    row.addCell().text = visit.boys.toString();
    row.addCell().text = visit.women.toString();
    row.addCell().text = visit.men.toString();
  }
}