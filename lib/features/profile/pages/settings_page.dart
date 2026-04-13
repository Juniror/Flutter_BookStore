import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../../auth/pages/login_page.dart';
import '../../../core/extensions/user_extensions.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/utils/ui_utils.dart';

/// A comprehensive settings page for managing account details, preferences, and security.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  final _user = FirebaseAuth.instance.currentUser;
  final _role = UserService.currentRole;

  @override
  void initState() {
    super.initState();
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // 1. Account Section
                  _buildSectionTitle('Account Profile'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    children: [
                      _buildInfoRow(
                        Icons.person_outline,
                        'Display Name',
                        _user?.displayNameOrEmail ?? 'Reader',
                        onTap: _showEditNameDialog,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.email_outlined,
                        'Email Address',
                        _user?.email ?? 'Not set',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.workspace_premium_outlined,
                        'Account Role',
                        _role?.toUpperCase() ?? 'USER',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 2. Preferences
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    children: [
                      _buildToggleRow(
                        Icons.notifications_active_outlined,
                        'Push Notifications',
                        _notificationsEnabled,
                        (val) => setState(() => _notificationsEnabled = val),
                      ),
                      _buildDivider(),
                      _buildActionRow(
                        Icons.palette_outlined,
                        'Theme & Decoration',
                        _showThemePicker,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. Security & App
                  _buildSectionTitle('Security & About'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    children: [
                      _buildActionRow(
                        Icons.lock_outline,
                        'Change Password',
                        () {
                          UIUtils.showInfoSnackBar(
                            context,
                            'Password reset email sent to ${_user?.email}',
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildActionRow(Icons.info_outline, 'About v1.0.1', () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Digital Library',
                          applicationVersion: '1.0.1',
                          applicationIcon: Icon(
                            Icons.book,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 4. Logout Action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout from Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.isDarkMode
                            ? Colors.red.withAlpha(20)
                            : Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Managed by DeepMind Studio',
                      style: TextStyle(
                        color: context.isDarkMode
                            ? Colors.white24
                            : Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _user?.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            labelText: 'Display Name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && _user != null) {
                try {
                  await UserService.updateUserProfile(_user.uid, newName);
                  if (!context.mounted) return;
                  setState(() {}); // Refresh UI
                  Navigator.pop(context);
                  UIUtils.showSuccessSnackBar(
                    context,
                    'Name updated successfully!',
                  );
                } catch (e) {
                  if (mounted) {
                    UIUtils.showErrorSnackBar(
                      context,
                      'Failed to update name: $e',
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      UserService.clearCache();
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // Subtle ripple
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withAlpha(100),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).iconTheme.color?.withAlpha(180),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor.withAlpha(180),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withAlpha(80),
            ),
          ],
        ),
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
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Preferences & Account',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Theme & Decoration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await ThemeService.instance.randomizePalette();
                    if (!mounted) return;
                    setState(() {});
                    if (navigator.canPop()) navigator.pop();
                    if (context.mounted) {
                      UIUtils.showSuccessSnackBar(
                        context,
                        'New coordinated theme generated!',
                      );
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shuffle_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a curated palette or randomize for a unique look.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildPaletteOption('Ocean', [
              const Color(0xFF2563EB),
              const Color(0xFF0EA5E9),
              const Color(0xFF06B6D4),
            ]),
            const SizedBox(height: 12),
            _buildPaletteOption('Sunset', [
              const Color(0xFF7C3AED),
              const Color(0xFFDB2777),
              const Color(0xFFF59E0B),
            ]),
            const SizedBox(height: 12),
            _buildPaletteOption('Forest', [
              const Color(0xFF059669),
              const Color(0xFF10B981),
              const Color(0xFF84CC16),
            ]),
            const SizedBox(height: 12),
            _buildPaletteOption('Midnight', [
              const Color(0xFF1E293B),
              const Color(0xFF4338CA),
              const Color(0xFF6366F1),
            ]),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteOption(String name, List<Color> colors) {
    final currentPalette = ThemeService.instance.currentPalette.value;
    final isSelected =
        currentPalette.length == colors.length &&
        currentPalette[0].toARGB32() == colors[0].toARGB32() &&
        currentPalette[1].toARGB32() == colors[1].toARGB32();

    return InkWell(
      onTap: () async {
        final navigator = Navigator.of(context);
        await ThemeService.instance.setPalette(colors);
        if (!mounted) return;
        setState(() {});
        navigator.pop();
        if (context.mounted) {
          UIUtils.showSuccessSnackBar(context, '$name palette applied!');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withAlpha(20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            Row(
              children: colors
                  .map(
                    (c) => Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withAlpha(20),
      indent: 20,
      endIndent: 20,
    );
  }
}
