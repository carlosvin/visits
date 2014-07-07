
import 'dart:html';
import 'dart:async';
import 'visits_db.dart';

void main() {

  if (DB.isSupported()){
    DB db = new DB();
    db.open().whenComplete(drawList(db));
    new VisitFormView(db);
    
    
  }else{
    var p = querySelector("#main_msg");
      p..text = 'Necesitas un navegador más moderno'
       ..classes.add('error'); 
  }
}

drawList (DB db){
  TableElement table = querySelector("#visits_table");
     for (Visit v in db.visits){
       new VisitRowView(v, table.addRow());
     }
}


class VisitFormView{
  
  Visit visit;
  DB db;
  DateInputElement dateInput;
  NumberInputElement boysInput, girslInput, menInput, womenInput;
  ButtonElement button;
  Element form;
  
  VisitFormView(DB db){
    this.db = db;
    visit = new Visit();
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
    
    dumpToForm();
  }
  
  void loadFromForm(){
    visit.boys = boysInput.valueAsNumber;
    visit.girls = girslInput.valueAsNumber;
    visit.men = menInput.valueAsNumber;
    visit.women = womenInput.valueAsNumber;
    visit.date = dateInput.valueAsDate;
  }
  
  void dumpToForm(){
    boysInput.valueAsNumber = visit.boys;
    girslInput.valueAsNumber = visit.girls;
    womenInput.valueAsNumber = visit.women;
    menInput.valueAsNumber = visit.men;
    dateInput.valueAsDate = visit.date;
  }
  
  void save(){
    loadFromForm();
    db.add(visit).whenComplete(saved);
  }
  
  void saved(){
    window.alert("Saved " + visit.getKey());
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