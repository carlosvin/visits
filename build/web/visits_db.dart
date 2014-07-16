library visits_db;

import 'dart:html';
import 'dart:async';
import 'dart:indexed_db';
import 'visits.dart';

class DB {
  
  final String store, dbName, index;
  Database _db;
  Map<String,Visit> visits = new Map();
  
  DB(this.store, this.dbName, this.index);
  
  Future open() {
    return window.indexedDB.open(
        dbName,
        version: 1,
        onUpgradeNeeded: _initializeDatabase)
      .then(_loadFromDB);
  }

  void _initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target as Request).result;
    
    var objectStore = db.createObjectStore(store,
        autoIncrement: true);
    var indx = objectStore.createIndex(index, 'date',
        unique: true);
  }
  
  Future _loadFromDB(Database db) {
    _db = db;

    var trans = db.transaction(this.store, 'readonly');
    var store = trans.objectStore(this.store);

    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      var visit = new Visit.fromRaw(cursor.value);
      visits[visit.getKey()] = visit;
    });

    return cursors.length.then((_) {
      return visits.length;
    });
  }
  
  Future<Visit> add(Visit visit) {
     var visitAsMap = visit.toRaw();

     var transaction = _db.transaction(store, 'readwrite');
     var objectStore = transaction.objectStore(store);
     
     objectStore.add(visitAsMap, visit.getKey()).then((addedKey) {
       if (visit.getKey() == addedKey){
        print("ok: " +  addedKey);
       }else{
         print("err: " + addedKey + " != " + visit.getKey());
       }
     });
     
     return transaction.completed.then((_) {
       visits[visit.getKey()]=visit;
       return visit;
     });
   }
  
  Future<Visit> update(Visit visit) {
     var visitAsMap = visit.toRaw();

     var transaction = _db.transaction(store, 'readwrite');
     var objectStore = transaction.objectStore(store);
     
     objectStore.put(visitAsMap, visit.getKey()).
      then((_)=>print("Updated " + visit.getKey())).
      catchError((err)=>print(err));

     return transaction.completed.then((_) {
       visits[visit.getKey()] = visit;
       return visit;
     }).catchError((err)=> print(err));
   }
   
   Future remove(Visit visit) {
     var transaction = _db.transaction(store, 'readwrite');
     transaction.objectStore(store).delete(visit.getKey());
     
     return transaction.completed.then((_) {
       visits.remove(visit);
       visit.date = null;
     });
   }
   
   // Removes ALL visits.
   Future clear() {
     var transaction = _db.transaction(store, 'readwrite');
     transaction.objectStore(store).clear();
     
     return transaction.completed.then((_) {
       visits.clear();
     });
   }
   
   static bool isSupported(){
     return IdbFactory.supported;
   }
}