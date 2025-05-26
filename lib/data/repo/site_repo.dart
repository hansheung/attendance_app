import 'package:attendance_app/data/model/site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiteRepo{
  static SiteRepo _instance = SiteRepo._init();

  SiteRepo._init();

  factory SiteRepo(){
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("sites");

  //Stream is same as Kotlin flow, not need async await
  Stream<List<Site>> getAllSites() {
    return _collection.snapshots().map((event) { 
      return event.docs.map((doc) {
        return Site.fromMap(doc.data()).copy(docId:doc.id);
      }).toList();
    });
  }

  // Future<Todo?> getTodoById(String docId) async{
  //   final res = await _collection.doc(docId).get();
  //   if((res.data() == null)){
  //     return null;
  //   }
  //   return Todo.fromMap(res.data()!).copy(docId: res.id);
  // }

  // Future<void> addTodo(Todo todo) async{
  //   await _collection.add(todo.toMap());
  // }

  // Future<void> updateTodo(Todo todo) async{
  //   await _collection.doc(todo.docId!).set(todo.toMap());
  // }

  // Future<void> deleteTodo(String docId) async {
  //   await _collection.doc(docId).delete();
  // }
}