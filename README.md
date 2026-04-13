# 📚 Book Library

A digital library management application built with Flutter and Firebase. This app allows users to browse, borrow, favorite, and read books directly from their device.

## ✨ Features

### 📖 Book Management
- **Browse Books** — View a curated catalog of books on the home page with trending and category sections.
- **Book Detail** — View comprehensive information about each book including cover image, author, description, and availability.
- **Search** — Search books by title, author, or category on a dedicated search page.
- **PDF Reader** — Read books directly within the app using the built-in PDF viewer.

### 📋 User Library
- **Borrow Books** — Borrow books with pickup or delivery options and track active borrows.
- **Favorites** — Save books to a personal favorites list for quick access.
- **Custom Folders** — Organize books into custom named collections.
- **Reading History** — Automatically tracks recently read books with a "Continue Reading" feature on the profile page.

### 🔐 Authentication
- **Login & Registration** — Secure user authentication powered by Firebase Auth.
- **Role-Based Access** — Supports Admin and User roles with the ability to toggle between them.

### 👤 Profile & Settings
- **User Profile** — Displays user information, account role, and quick navigation to library features.
- **Account Settings** — Update display name, change password, and manage preferences.
- **Dynamic Theming** — Switch between curated color palettes (Ocean, Sunset, Forest, Midnight) or randomize for a unique look.
- **Dark Mode Support** — Full light and dark theme support across the entire app.

## 🏗️ Architecture

The project follows a **feature-based layered architecture**:

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared infrastructure
│   ├── constants/               # Firebase config & constants
│   ├── extensions/              # Dart extension methods
│   ├── navigation/              # Bottom navigation shell
│   ├── services/                # Core services (caching, etc.)
│   ├── theme/                   # Theme data & dynamic theme service
│   ├── utils/                   # UI utilities & helpers
│   └── widgets/                 # Reusable widget library
└── features/                    # Feature modules
    ├── auth/                    # Authentication (Login)
    │   ├── pages/
    │   └── services/
    ├── books/                   # Book catalog & management
    │   ├── models/              # Data models (Book, BorrowRecord, etc.)
    │   ├── pages/               # Screens (Home, Detail, Reader, etc.)
    │   ├── services/            # Business logic (Borrow, Favorite, etc.)
    │   └── widgets/             # Book-specific UI components
    └── profile/                 # User profile & settings
        ├── pages/
        ├── services/
        └── widgets/
```

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Firebase Core** | Firebase initialization |
| **Cloud Firestore** | Real-time NoSQL database |
| **Firebase Auth** | User authentication |
| **Syncfusion PDF Viewer** | In-app PDF reading |
| **Cached Network Image** | Image caching & loading |
| **Shimmer** | Loading placeholder animations |
| **Shared Preferences** | Local theme persistence |
| **Intl** | Date formatting & internationalization |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.11.0`
- A configured Firebase project with Firestore and Authentication enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd book_library
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Place your `firebase_options.dart` in `lib/core/constants/`.
   - Ensure Firestore rules allow read/write for authenticated users.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Data Models

| Model | Description |
|---|---|
| `Book` | Core book entity with title, author, categories, cover image, PDF URL, and availability |
| `BorrowRecord` | Tracks book borrows with type (pickup/delivery), status, and dates |
| `FavoriteRecord` | Stores user's favorited books |
| `ReadingHistory` | Records recently read books for the "Continue Reading" feature |
| `Review` | User reviews and ratings for books |
| `UserFolder` | Custom user-created collections of books |

## 📸 Key Screens

| Screen | Description |
|---|---|
| **Home** | Greeting header, trending books, and category browsing |
| **Book Detail** | Full book info with borrow, favorite, save, and folder actions |
| **PDF Reader** | Built-in reader for viewing book content |
| **Search** | Filter and search across the entire catalog |
| **Profile** | User info, role badge, continue reading banner, and menu navigation |
| **Settings** | Account management, theme picker, and preferences |
| **Borrowed Books** | Active and past borrow records |
| **Favorites** | Personal favorites collection |
| **Custom Folders** | User-created book collections |
| **Reading History** | Chronological reading activity log |

## 📄 License

This project is for educational purposes.
