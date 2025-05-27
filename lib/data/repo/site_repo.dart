import 'package:attendance_app/data/model/site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiteRepo {
  static SiteRepo _instance = SiteRepo._init();

  SiteRepo._init();

  factory SiteRepo() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("sites");

  //Stream is same as Kotlin flow, not need async await
  Future<List<Site>> getAllSites() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      return Site.fromMap(doc.data()).copy(docId: doc.id);
    }).toList();
  }

  Future<Site?> getSiteById(String docId) async {
    final res = await _collection.doc(docId).get();
    if ((res.data() == null)) {
      return null;
    }
    return Site.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<void> addSite(Site site) async {
    await _collection.add(site.toMap());
  }

  Future<void> updateSite(Site site) async {
    await _collection.doc(site.docId!).set(site.toMap());
  }

  Future<void> deleteSite(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<Site?> getSiteByName(String name) async {
    final querySnapshot =
        await _collection.where('sitename', isEqualTo: name).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    return Site.fromMap(doc.data()).copy(docId: doc.id);
  }
}
