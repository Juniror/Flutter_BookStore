import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';

/// Represents a user-created collection or folder for organizing books.
class UserFolder {
  final String id;
  final String ownerId;
  final String name;
  final List<String> bookIds;
  final DateTime createdAt;

  UserFolder({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.bookIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fields.folderOwnerId: ownerId,
      FirebaseConstants.fields.folderName: name,
      FirebaseConstants.fields.folderBookIds: bookIds,
      FirebaseConstants.fields.folderCreatedAt: Timestamp.fromDate(createdAt),
    };
  }

  factory UserFolder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFolder(
      id: doc.id,
      ownerId: data[FirebaseConstants.fields.folderOwnerId] ?? '',
      name: data[FirebaseConstants.fields.folderName] ?? '',
      bookIds: List<String>.from(data[FirebaseConstants.fields.folderBookIds] ?? []),
      createdAt: (data[FirebaseConstants.fields.folderCreatedAt] as Timestamp).toDate(),
    );
  }
}
