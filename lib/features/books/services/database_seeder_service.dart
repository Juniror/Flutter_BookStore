import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/firebase_constants.dart';

/// One-time utility service to populate the database with REAL books and STABLE direct images.
/// This version uses high-stability assets from Standard Ebooks.
class DatabaseSeederService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedBooks() async {
    // CRITICAL: Prevent data seeding in production.
    if (!kDebugMode) return;
    
    final booksCollection = _db.collection(FirebaseConstants.collections.books);
    final batch = _db.batch();

    final List<Map<String, dynamic>> sampleBooks = [
      {
        'title': 'Alice\'s Adventures in Wonderland',
        'author': 'Lewis Carroll',
        'category': ['Fantasy', 'Classic'],
        'publishedYear': '1865',
        'totalCopies': 10,
        'availableCopies': 10,
        'description': 'A young girl named Alice falls through a rabbit hole into a fantasy world.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/lewis-carroll/alices-adventures-in-wonderland/john-tenniel/downloads/cover.jpg',
        'pdfUrl': 'https://ia600300.us.archive.org/16/items/AlicesAdventuresInWonderland/alice-in-wonderland.pdf',
        'averageRating': 4.7,
        'reviewCount': 210,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'The Adventures of Sherlock Holmes',
        'author': 'Arthur Conan Doyle',
        'category': ['Mystery', 'Classic'],
        'publishedYear': '1892',
        'totalCopies': 5,
        'availableCopies': 5,
        'description': 'The famous detective solves a variety of complex mysteries.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/arthur-conan-doyle/the-adventures-of-sherlock-holmes/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/adventuresofsher001892doyl/adventuresofsher001892doyl.pdf',
        'averageRating': 4.8,
        'reviewCount': 150,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Frankenstein',
        'author': 'Mary Shelley',
        'category': ['Horror', 'Classic'],
        'publishedYear': '1818',
        'totalCopies': 3,
        'availableCopies': 3,
        'description': 'Victor Frankenstein creates a sapient creature in an unorthodox experiment.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/mary-shelley/frankenstein/downloads/cover.jpg',
        'pdfUrl': 'https://ia802908.us.archive.org/9/items/Frankenstein1818Edition/frank-a5.pdf',
        'averageRating': 4.5,
        'reviewCount': 140,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'category': ['Romance', 'Classic'],
        'publishedYear': '1813',
        'totalCopies': 8,
        'availableCopies': 8,
        'description': 'A story of love and manners in the Regency era of Great Britain.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/prideprejudice00aust/prideprejudice00aust.pdf',
        'averageRating': 4.9,
        'reviewCount': 300,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Treasure Island',
        'author': 'Robert Louis Stevenson',
        'category': ['Adventure', 'Classic'],
        'publishedYear': '1883',
        'totalCopies': 4,
        'availableCopies': 4,
        'description': 'A tale of pirates and buried gold, focusing on Jim Hawkins.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/robert-louis-stevenson/treasure-island/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/islandtreasure00stevrich/islandtreasure00stevrich.pdf',
        'averageRating': 4.6,
        'reviewCount': 95,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Dracula',
        'author': 'Bram Stoker',
        'category': ['Horror', 'Classic'],
        'publishedYear': '1897',
        'totalCopies': 2,
        'availableCopies': 2,
        'description': 'The story of Count Dracula\'s attempt to move from Transylvania to England.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/bram-stoker/dracula/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/draculabr00stokuoft/draculabr00stokuoft.pdf',
        'averageRating': 4.3,
        'reviewCount': 110,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Jane Eyre',
        'author': 'Charlotte Brontë',
        'category': ['Drama', 'Classic'],
        'publishedYear': '1847',
        'totalCopies': 6,
        'availableCopies': 6,
        'description': 'The growth and love story of Jane Eyre and Mr. Rochester.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/charlotte-bronte/jane-eyre/downloads/cover.jpg',
        'pdfUrl': 'https://ia601305.us.archive.org/24/items/JaneEyre-CharlotteBronte/jane_eyre.pdf',
        'averageRating': 4.6,
        'reviewCount': 130,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Moby Dick',
        'author': 'Herman Melville',
        'category': ['Adventure', 'Classic'],
        'publishedYear': '1851',
        'totalCopies': 7,
        'availableCopies': 7,
        'description': 'Captain Ahab\'s obsessive quest to seek revenge on the white whale.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/herman-melville/moby-dick/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/mobydickorwhale01melv/mobydickorwhale01melv.pdf',
        'averageRating': 4.1,
        'reviewCount': 80,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Gulliver\'s Travels',
        'author': 'Jonathan Swift',
        'category': ['Fantasy', 'Satire'],
        'publishedYear': '1726',
        'totalCopies': 12,
        'availableCopies': 12,
        'description': 'Lemuel Gulliver travels to remote and mysterious islands.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/jonathan-swift/gullivers-travels/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/gulliverstravels1918swif/gulliverstravels1918swif.pdf',
        'averageRating': 4.4,
        'reviewCount': 160,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Wuthering Heights',
        'author': 'Emily Brontë',
        'category': ['Drama', 'Classic'],
        'publishedYear': '1847',
        'totalCopies': 5,
        'availableCopies': 5,
        'description': 'A tragic story of love and revenge on the Yorkshire moors.',
        'coverImageUrl': 'https://standardebooks.org/ebooks/emily-bronte/wuthering-heights/downloads/cover.jpg',
        'pdfUrl': 'https://archive.org/download/wutheringheights01bron/wutheringheights01bron.pdf',
        'averageRating': 4.5,
        'reviewCount': 145,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var bookData in sampleBooks) {
      final docId = (bookData['title'] as String).toLowerCase().replaceAll(' ', '_').replaceAll('\'', '');
      final docRef = booksCollection.doc(docId);
      batch.set(docRef, bookData, SetOptions(merge: true));
    }

    await batch.commit();
    debugPrint('Successfully seeded 10 books with PERMANENT Standard Ebooks links.');
  }
}
