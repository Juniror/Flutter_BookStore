import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';

/// The header section for the HomePage, including greeting and search bar.
class HomeHeader extends StatelessWidget {
  final String userName;
  final String greeting;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: context.gradients.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                _buildGreetingSection(),
                _buildNotificationButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white12,
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'R',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () => UIUtils.showInfoSnackBar(context, 'No new notifications'),
      ),
    );
  }
}
