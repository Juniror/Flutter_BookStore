import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';
import '../models/user_folder.dart';
import '../models/book.dart';

/// Service for managing user-defined book collections (folders).
class UserFolderService extends BaseService {
  static CollectionReference get _folderCollection =>
      BaseService.firestore.collection(FirebaseConstants.collections.userFolders);

  /// Returns a stream of folders owned by the specified [userId].
  /// Results are sorted alphabetically by folder name.
  static Stream<List<UserFolder>> getUserFolders(String userId) {
    return _folderCollection
        .where(FirebaseConstants.fields.folderOwnerId, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map((doc) => UserFolder.fromFirestore(doc)).toList();
      folders.sort((a, b) => a.name.compareTo(b.name));
      return folders;
    });
  }

  /// Creates a new folder with the given [name] for the specified [userId].
  /// Throws an [Exception] if the name is empty.
  static Future<void> createFolder(String userId, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Folder name cannot be empty.');
    }

    final folder = UserFolder(
      id: '',
      ownerId: userId,
      name: trimmedName,
      bookIds: [],
      createdAt: DateTime.now(),
    );
    await _folderCollection.add(folder.toMap());
  }

  /// Appends [bookId] to the specified [folderId].
  static Future<void> addBookToFolder(String folderId, String bookId) async {
    await _folderCollection.doc(folderId).update({
      FirebaseConstants.fields.folderBookIds: FieldValue.arrayUnion([bookId]),
    });
  }

  /// Removes [bookId] from the specified [folderId].
  static Future<void> removeBookFromFolder(String folderId, String bookId) async {
    await _folderCollection.doc(folderId).update({
      FirebaseConstants.fields.folderBookIds: FieldValue.arrayRemove([bookId]),
    });
  }

  /// Permanently removes the folder specified by [folderId].
  static Future<void> deleteFolder(String folderId) async {
    await _folderCollection.doc(folderId).delete();
  }

  /// Returns a stream of [Book] objects derived from a list of [bookIds].
  /// Queries are chunked to satisfy Firestore's limit of 30 items per `whereIn` clause.
  static Stream<List<Book>> getBooksByIds(List<String> bookIds) {
    if (bookIds.isEmpty) return Stream.value([]);
    
    // Chunk size is 30 for whereIn
    const int chunkSize = 30;
    final List<List<String>> chunks = [];
    for (var i = 0; i < bookIds.length; i += chunkSize) {
      chunks.add(bookIds.sublist(i, i + chunkSize > bookIds.length ? bookIds.length : i + chunkSize));
    }

    final streams = chunks.map((chunk) => BaseService.firestore
        .collection(FirebaseConstants.collections.books)
        .where(FieldPath.documentId, whereIn: chunk)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList()));

    return _CombineStreams(streams.toList()).stream;
  }
}

/// Helper class to combine multiple Firestore streams into one list
class _CombineStreams {
  final List<Stream<List<Book>>> streams;
  final StreamController<List<Book>> _controller = StreamController<List<Book>>.broadcast();
  final List<List<Book>> _latestData;
  final List<StreamSubscription> _subscriptions = [];

  _CombineStreams(this.streams) : _latestData = List.filled(streams.length, []) {
    for (int i = 0; i < streams.length; i++) {
      _subscriptions.add(streams[i].listen((data) {
        _latestData[i] = data;
        _controller.add(_latestData.expand((x) => x).toList());
      }));
    }

    _controller.onCancel = () {
      for (var sub in _subscriptions) {
        sub.cancel();
      }
    };
  }

  Stream<List<Book>> get stream => _controller.stream;
}
