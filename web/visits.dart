
import 'dart:html';
import 'dart:indexed_db';
import 'dart:async';

void main() {
  if (IdbFactory.supported){
    DB db = new DB();
    db.open();
    new VisitFormView(db);
    
    TableElement table = querySelector("#visits_table");
    for (Visit v in db.visits){
      new VisitRowView(v, table.addRow());
    }
  }else{
    var p = querySelector("#main_msg");
      p..text = 'Necesitas un navegador más moderno'
       ..classes.add('error'); 
  }
}

class DB {
  static const String VISITS_STORE = 'visitsStore';
  static const String VISITS_DB = 'visitsDB';
  static const String NAME_INDEX = 'name_index';
  
  var _db;
  List<Visit> visits = new List();
  
  Future open() {
    return window.indexedDB.open(VISITS_DB,
        version: 1,
        onUpgradeNeeded: _initializeDatabase)
      .then(_loadFromDB);
  }

  void _initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target as Request).result;
    
    var objectStore = db.createObjectStore(VISITS_STORE,
        autoIncrement: true);
    var index = objectStore.createIndex(NAME_INDEX, 'milestoneName',
        unique: true);
  }
  
  Future _loadFromDB(Database db) {
    _db = db;

    var trans = db.transaction(VISITS_STORE, 'readonly');
    var store = trans.objectStore(VISITS_STORE);

    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      var visit = new Visit.fromRaw(cursor.key, cursor.value);
      visits.add(visit);
    });

    return cursors.length.then((_) {
      return visits.length;
    });
  }
  
 
  Future<Visit> add(Visit visit) {
     var visitAsMap = visit.toRaw();

     var transaction = _db.transaction(VISITS_STORE, 'readwrite');
     var objectStore = transaction.objectStore(VISITS_STORE);
     
     objectStore.add(visitAsMap).then((addedKey) {
       // NOTE! The key cannot be used until the transaction completes.
       visit.id = addedKey;
     });
     
     // Note that the visit cannot be queried until the transaction
     // has completed!
     return transaction.completed.then((_) {
       // Once the transaction completes, add it to our list of available items.
       visits.add(visit);
       
       // Return the milestone so this becomes the result of the future.
       return visit;
     });
   }
   
   // Removes a milestone from the list of milestones.
   // 
   // This returns a Future which completes when the milestone has been removed.
   Future remove(Visit visit) {
     // Remove from database.
     var transaction = _db.transaction(VISITS_STORE, 'readwrite');
     transaction.objectStore(VISITS_STORE).delete(visit.id);
     
     return transaction.completed.then((_) {
       // Null out the key to indicate that the milestone is dead.
       visit.id = null;
       // Remove from internal list.
       visits.remove(visit);
     });
   }
   
   // Removes ALL milestones.
   Future clear() {
     // Clear database.
     var transaction = _db.transaction(VISITS_STORE, 'readwrite');
     transaction.objectStore(VISITS_STORE).clear();
     
     return transaction.completed.then((_) {
       // Clear internal list.
       visits.clear();
     });
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
  }
  
  void loadFormInfo(){
    visit.boys = boysInput.valueAsNumber;
    visit.girls = girslInput.valueAsNumber;
    visit.men = menInput.valueAsNumber;
    visit.women = womenInput.valueAsNumber;
    visit.date = dateInput.valueAsDate;
  }
  
  void save(){
    loadFormInfo();
    Future<Visit> future = db.add(visit);
    future.whenComplete(saved);
  }
  
  void saved(){
    window.alert("Saved " + visit.id);
  }
}

class Visit{

  var id;
  DateTime date;
  var boys, girls, men, women;
  
  Visit(){
    date = new DateTime.now();
    boys = 0;
    girls = 0;
    men = 0;
    women = 0;
  }
  
  Visit.fromRaw(key, Map value):
    id = key,
    date = value['date'],
    boys = value['boys'],
    girls = value['girls'],
    men = value['men'],
    women = value['women'];
  
  
  Map toRaw() {
    return {
      'date': date,
      'boys': boys,
      'girls': girls,
      'men': men,
      'women': women,
    };
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