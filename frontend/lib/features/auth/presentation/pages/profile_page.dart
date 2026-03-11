import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../user_articles/presentation/bloc/user_articles/user_articles_bloc.dart';
import '../../../user_articles/presentation/bloc/user_articles/user_articles_event.dart';
import '../../../user_articles/presentation/bloc/user_articles/user_articles_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserArticles();
  }

  void _loadUserArticles() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user?.id != null) {
      context.read<UserArticlesBloc>().add(
            LoadUserArticles(userId: authState.user!.id!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/Login');
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildContent(context, state.user!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            if (value == 'edit') {
              // Navigate to edit profile
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, UserEntity user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildProfileHeader(user),
          const SizedBox(height: 24),
          _buildStats(),
          const SizedBox(height: 32),
          _buildSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    return Column(
      children: [
        // Profile Avatar
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5C9A0),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: user.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(Icons.person,
                            size: 60, color: Colors.white),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white),
                      )
                    : const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          user.displayName ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        // Title/Role
        const Text(
          'Senior Tech Correspondent',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF3B5BDB),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Bio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Independent journalist covering the intersection of emerging technology, global policy, and digital society.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return BlocBuilder<UserArticlesBloc, UserArticlesState>(
      builder: (context, state) {
        final articleCount = state.articles?.length ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStatItem('$articleCount', 'ARTICLES'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'ACCOUNT SETTINGS',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.settings_outlined,
          iconColor: Colors.grey[600]!,
          title: 'Settings',
          subtitle: 'Theme and language',
          onTap: () {
            Navigator.pushNamed(context, '/Settings');
          },
        ),
        const Divider(height: 32),
        _buildSettingsTile(
          icon: Icons.logout,
          iconColor: Colors.red,
          title: 'Logout',
          titleColor: Colors.red,
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    bool showBadge = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: subtitle != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBadge)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B5BDB),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
