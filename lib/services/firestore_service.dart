import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_item.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User get _user {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    return user;
  }

  static DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_user.uid);

  static CollectionReference<Map<String, dynamic>> get _documents =>
      _userDoc.collection('documents');

  static Future<void> ensureUserProfile({String? name}) async {
    final user = _user;
    final snapshot = await _userDoc.get();
    final data = snapshot.data();
    await _userDoc.set({
      'name': (data?['name'] as String?)?.trim().isNotEmpty == true
          ? data!['name']
          : (name?.trim().isNotEmpty == true
              ? name!.trim()
              : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : 'Valid user')),
      'email': user.email ?? '',
      'createdAt': data?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'settings': data?['settings'] ?? {
        'expiryNotifications': true,
        'haptics': true,
        'defaultReminder': '30 days before',
        'appearance': 'Light',
      },
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final doc = await _userDoc.get();
    return doc.data() ?? <String, dynamic>{};
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await _userDoc.set({
      'name': name.trim(),
      'email': email.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> updateSettings({
    required bool expiryNotifications,
    required bool haptics,
    required String defaultReminder,
    required String appearance,
  }) async {
    await _userDoc.set({
      'settings': {
        'expiryNotifications': expiryNotifications,
        'haptics': haptics,
        'defaultReminder': defaultReminder,
        'appearance': appearance,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<DocumentItem>> getDocuments() async {
    final snapshot = await _documents.get();
    final items = snapshot.docs
        .map((doc) => DocumentItem.fromFirestore(doc.id, doc.data()))
        .toList();
    items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return items;
  }

  static Future<void> addDocument(DocumentItem item) async {
    await _documents.doc(item.id).set(item.toFirestore(isNew: true));
  }

  static Future<void> updateDocument(DocumentItem item) async {
    await _documents.doc(item.id).set(item.toFirestore(isNew: false), SetOptions(merge: true));
  }

  static Future<void> deleteDocument(String id) => _documents.doc(id).delete();

  static Future<void> submitSupportMessage({
    required String subject,
    required String message,
  }) async {
    await _userDoc.collection('supportMessages').add({
      'subject': subject.trim(),
      'message': message.trim(),
      'email': _user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'new',
    });
  }
}
