import 'dart:html';
import 'dart:async';
import 'visits.dart';
import 'dart:indexed_db';

class DB {
  static const String VISITS_STORE = 'visitsStore';
  static const String VISITS_DB = 'visitsDB';
  static const String DATE_INDEX = 'date_index';
  
  var _db;
  List<Visit> visits = new List();
  
  Future open() {
    return window.indexedDB.open(VISITS_DB,
        version: 1,
        onUpgradeNeeded: _initializeDatabase)
      .then(_loadFromDB)
      .catchError(_onError);
  }

  void _initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target as Request).result;
    
    var objectStore = db.createObjectStore(VISITS_STORE,
        autoIncrement: true);
    var index = objectStore.createIndex(DATE_INDEX, 'date',
        unique: true);
  }
  
  void _onError(e) {
    window.alert('Oh no! Something went wrong. See the console for details.');
    window.console.log('An error occurred: {$e}');
  }
  
  Future _loadFromDB(Database db) {
    _db = db;

    var trans = db.transaction(VISITS_STORE, 'readonly');
    var store = trans.objectStore(VISITS_STORE);

    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      var visit = new Visit.fromRaw(cursor.value);
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
     
     objectStore.add(visitAsMap, visit.getKey()).then((addedKey) {
       if (visit.getKey() == addedKey){
        print("ok: " +  addedKey);
       }else{
         print("err: " + addedKey + " != " + visit.getKey());
       }
     });
     
     // Note that the visit cannot be queried until the transaction
     // has completed!
     return transaction.completed.then((_) {
       // Once the transaction completes, add it to our list of available items.
       visits.add(visit);
       
       // Return the visit so this becomes the result of the future.
       return visit;
     });
   }
   
   // Removes a visit from the list of visits.
   // 
   // This returns a Future which completes when the visit has been removed.
   Future remove(Visit visit) {
     // Remove from database.
     var transaction = _db.transaction(VISITS_STORE, 'readwrite');
     transaction.objectStore(VISITS_STORE).delete(visit.getKey());
     
     return transaction.completed.then((_) {
       // Remove from internal list.
       visits.remove(visit);
       // Null out the key to indicate that the visit is dead.
       visit.date = null;
     });
   }
   
   // Removes ALL visits.
   Future clear() {
     // Clear database.
     var transaction = _db.transaction(VISITS_STORE, 'readwrite');
     transaction.objectStore(VISITS_STORE).clear();
     
     return transaction.completed.then((_) {
       // Clear internal list.
       visits.clear();
     });
   }
   
   static bool isSupported(){
     return IdbFactory.supported;
   }
}