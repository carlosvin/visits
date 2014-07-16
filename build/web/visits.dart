library visits;

import 'dart:html';
import 'visits_db.dart';
import 'dart:async';

String VISITS_STORE = 'visitsStore';
String VISITS_DB = 'visitsDatabase';
String DATE_INDEX = 'date_index';

void main() {

  if (DB.isSupported()){
    DB db = new DB(VISITS_STORE, VISITS_DB, DATE_INDEX);
    VisitList visitList = new VisitList();
    VisitFormView visitForm = new VisitFormView(db, visitList);
    
    db.open().
      then(visitList.drawList(db.visits.values, visitForm)).
      catchError(onError);


  }else{
    querySelector("#main_msg")
        ..text = 'Necesitas un navegador más moderno'
        ..classes.add('error'); 
  }
}

onError(e){
  print("error opening " + e.toString());
}

class VisitList {
  
  TableElement _table;
  Map<String, TableRowElement> rows = new Map();
  
  VisitList(){
    _table = querySelector("#visits_table");
  }
  
  drawList (Iterable<Visit> visits, VisitFormView form){
    for (Visit v in visits){
      update(v, form);
    }
  }
  
  update(Visit visit, VisitFormView form){
    TableRowElement row;
    if (rows.containsKey(visit.getKey())){
      row = rows[visit.getKey()];    
    }else{
      row = _table.addRow();
      for (var i=0; i<5; i++){
        row.addCell();
      }
      row.onClick.listen((MouseEvent e){
        form.loadToFrom(visit);
      });
      rows[visit.getKey()] = row;
    }
    
    row.cells[0].text = visit.date.toLocal().toString();
    row.cells[1].text = visit.girls.toString();
    row.cells[2].text = visit.boys.toString();
    row.cells[3].text = visit.women.toString();
    row.cells[4].text = visit.men.toString();
    
  }

}

class VisitFormView{
  
  Visit _visit;
  DB _db;
  
  //DB db;
  DateInputElement dateInput;
  NumberInputElement boysInput, girslInput, menInput, womenInput;
  ButtonElement button;
  Element form;
  
  VisitFormView(DB db, VisitList list){
    _visit = new Visit();
    _db = db;
    dateInput = new DateInputElement();
    boysInput = new NumberInputElement();
    girslInput = new NumberInputElement();
    menInput = new NumberInputElement();
    womenInput = new NumberInputElement();
    button = new ButtonElement();
    button..id = 'save'
          ..text = 'Salvar'
          ..classes.add('important')
          ..onClick.listen((e) => save(e).then((visit)=>list.update(visit, this)).catchError((err) => print(err)));
    
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
    loadFromForm();
  }
  
  Future<Visit> save(Event e){
    e.preventDefault(); 
    loadFromForm();
    if (_db.visits.containsKey(_visit.getKey())){
      return _db.update(_visit);
    }else{
      return _db.add(_visit);
    }
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
