import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/pages/login_page.dart';
import '../services/user_service.dart';
import '../../../core/constants/firebase_constants.dart';
import '../widgets/profile_menu_button.dart';
import '../../books/pages/borrowed_books_page.dart';
import '../../books/pages/favorite_books_page.dart';
import '../../books/pages/custom_folders_page.dart';
import '../../books/pages/reading_history_page.dart';
import '../../books/pages/book_detail_page.dart';
import '../../books/models/book.dart';
import '../../books/models/reading_history.dart';
import '../../books/services/history_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/extensions/user_extensions.dart';
import 'settings_page.dart';

/// Displays the user's profile information, account role, and navigation to key features.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userRole;
  final _user = AuthService.currentUser;
  bool _isLoadingRole = true;
  bool _isUpdatingRole = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (_user != null) {
      if (UserService.currentRole == null) {
        await UserService.initializeUserProfile(_user.uid);
      }
      if (mounted) {
        setState(() {
          _userRole = UserService.currentRole;
          _isLoadingRole = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingRole = false;
        });
      }
    }
  }

  Future<void> _toggleRole() async {
    if (_user == null || _isUpdatingRole) return;

    final newRole = _userRole == FirebaseConstants.roles.admin
        ? FirebaseConstants.roles.user
        : FirebaseConstants.roles.admin;

    setState(() => _isUpdatingRole = true);

    try {
      await UserService.updateRole(_user.uid, newRole);

      if (mounted) {
        setState(() {
          _userRole = newRole;
          _isUpdatingRole = false;
        });

        UIUtils.showSuccessSnackBar(
          context,
          'Successfully changed role to $newRole!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingRole = false);
        UIUtils.showErrorSnackBar(context, 'Failed to update role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(child: _buildContinueReadingBanner(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Management',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileMenuButton(
                    title: 'Borrowed Books',
                    icon: Icons.menu_book_rounded,
                    onTap: () =>
                        _navigateTo(context, const BorrowedBooksPage()),
                  ),
                  ProfileMenuButton(
                    title: 'Favorite Books',
                    icon: Icons.favorite_rounded,
                    onTap: () =>
                        _navigateTo(context, const FavoriteBooksPage()),
                  ),
                  ProfileMenuButton(
                    title: 'My Collections',
                    icon: Icons.folder_special_rounded,
                    onTap: () =>
                        _navigateTo(context, const CustomFoldersPage()),
                  ),
                  ProfileMenuButton(
                    title: 'Reading History',
                    icon: Icons.history_rounded,
                    onTap: () =>
                        _navigateTo(context, const ReadingHistoryPage()),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Preferences',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileMenuButton(
                    title: 'Account Settings',
                    icon: Icons.settings_rounded,
                    onTap: () => _navigateTo(context, const SettingsPage()),
                  ),
                  if (!_isLoadingRole)
                    ProfileMenuButton(
                      title: _userRole == FirebaseConstants.roles.admin
                          ? 'Switch to User View'
                          : 'Switch to Admin View',
                      icon: Icons.admin_panel_settings_rounded,
                      onTap: _toggleRole,
                      isLoading: _isUpdatingRole,
                    ),

                  const SizedBox(height: 24),
                  ProfileMenuButton(
                    title: 'Logout',
                    icon: Icons.logout_rounded,
                    isDestructive: true,
                    onTap: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          gradient: context.gradients.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).primaryColor.withAlpha(context.isDarkMode ? 40 : 60),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      child: Text(
                        _user.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!_isLoadingRole &&
                      _userRole == FirebaseConstants.roles.admin)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700), // Gold
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _user.displayNameOrEmail,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!_isLoadingRole && _userRole != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Text(
                    _userRole!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildContinueReadingBanner(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    return StreamBuilder<List<ReadingHistory>>(
      stream: HistoryService.getHistory(_user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final lastRead = snapshot.data!.first; // Most recent

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withAlpha(178), // ~0.7
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection(FirebaseConstants.collections.books)
                        .doc(lastRead.bookId)
                        .get();
                    if (context.mounted) Navigator.pop(context); // close loader
                    if (doc.exists) {
                      final book = Book.fromFirestore(doc);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(book: book),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        UIUtils.showErrorSnackBar(
                          context,
                          'This book is no longer available',
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      UIUtils.showErrorSnackBar(context, 'Failed to open book');
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue Reading',
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastRead.bookTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
