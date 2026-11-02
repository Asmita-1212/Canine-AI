import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? dog;
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, required this.user, this.dog, this.onLogout});

  static const Color navy = Color(0xFF163A5F);
  static const Color blue = Color(0xFF2878D0);
  static const Color teal = Color(0xFF14998E);
  static const Color purple = Color(0xFF7759CF);
  static const Color muted = Color(0xFF71839A);
  static const Color page = Color(0xFFF4F8FC);
  static const Color border = Color(0xFFE3EAF3);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color softTeal = Color(0xFFE7F7F2);
  static const Color softPurple = Color(0xFFF0EDFF);

  String _text(dynamic value, [String fallback = 'Not provided']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString().trim();
  }

  String get _name =>
      _text(user['full_name'] ?? user['name'] ?? user['username'], 'User');

  String get _initials {
    final parts = _name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get _role {
    final role = _text(user['role'], 'User');
    return '${role[0].toUpperCase()}${role.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 1100;
            final isTablet = width >= 650 && width < 1100;

            final horizontalPadding = isDesktop
                ? 32.0
                : isTablet
                ? 24.0
                : 16.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _appBar(context),
                      const SizedBox(height: 24),

                      _profileHero(
                        email: _text(user['email'], 'Email not provided'),
                        phone: _text(
                          user['phone'] ?? user['phone_number'],
                          'Phone not provided',
                        ),
                        isDesktop: isDesktop,
                      ),

                      const SizedBox(height: 30),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _sectionHeading(
                                    'App Information',
                                    'Help and discover more',
                                    Icons.info_outline_rounded,
                                    purple,
                                  ),
                                  const SizedBox(height: 14),
                                  _settingsGroup([
                                    _SettingItem(
                                      icon: Icons.verified_rounded,
                                      title: 'About CanineCare AI',
                                      subtitle: 'Learn about our application',
                                      color: blue,
                                      background: softBlue,
                                      onTap: () => _showAbout(context),
                                    ),
                                    _SettingItem(
                                      icon: Icons.support_agent_rounded,
                                      title: 'Help & Support',
                                      subtitle: 'Get assistance with the app',
                                      color: teal,
                                      background: softTeal,
                                      onTap: () =>
                                          _message(context, 'Help & Support'),
                                    ),
                                    _SettingItem(
                                      icon: Icons.star_rounded,
                                      title: 'Rate Us',
                                      subtitle: 'Share your feedback',
                                      color: purple,
                                      background: softPurple,
                                      onTap: () => _message(context, 'Rate Us'),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _sectionHeading(
                                    'Account Settings',
                                    'Manage your account preferences',
                                    Icons.manage_accounts_rounded,
                                    blue,
                                  ),
                                  const SizedBox(height: 14),
                                  _settingsGroup([
                                    _SettingItem(
                                      icon: Icons.person_rounded,
                                      title: 'Edit Profile',
                                      subtitle:
                                          'Update your personal information',
                                      color: blue,
                                      background: softBlue,
                                      onTap: () =>
                                          _message(context, 'Edit Profile'),
                                    ),
                                    _SettingItem(
                                      icon: Icons.lock_rounded,
                                      title: 'Change Password',
                                      subtitle: 'Keep your account secure',
                                      color: purple,
                                      background: softPurple,
                                      onTap: () =>
                                          _message(context, 'Change Password'),
                                    ),
                                    _SettingItem(
                                      icon: Icons.notifications_active_rounded,
                                      title: 'Notification Settings',
                                      subtitle: 'Manage alerts and reminders',
                                      color: teal,
                                      background: softTeal,
                                      onTap: () => _message(
                                        context,
                                        'Notification Settings',
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _sectionHeading(
                          'My Dog',
                          'Your companion’s information',
                          Icons.pets_rounded,
                          teal,
                        ),

                        const SizedBox(height: 28),
                        _sectionHeading(
                          'Account Settings',
                          'Manage your account preferences',
                          Icons.manage_accounts_rounded,
                          blue,
                        ),
                        const SizedBox(height: 14),
                        _settingsGroup([
                          _SettingItem(
                            icon: Icons.person_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            color: blue,
                            background: softBlue,
                            onTap: () => _message(context, 'Edit Profile'),
                          ),
                          _SettingItem(
                            icon: Icons.lock_rounded,
                            title: 'Change Password',
                            subtitle: 'Keep your account secure',
                            color: purple,
                            background: softPurple,
                            onTap: () => _message(context, 'Change Password'),
                          ),
                          _SettingItem(
                            icon: Icons.notifications_active_rounded,
                            title: 'Notification Settings',
                            subtitle: 'Manage alerts and reminders',
                            color: teal,
                            background: softTeal,
                            onTap: () =>
                                _message(context, 'Notification Settings'),
                          ),
                        ]),
                        const SizedBox(height: 28),
                        _sectionHeading(
                          'App Information',
                          'Help and discover more',
                          Icons.info_outline_rounded,
                          purple,
                        ),
                        const SizedBox(height: 14),
                        _settingsGroup([
                          _SettingItem(
                            icon: Icons.verified_rounded,
                            title: 'About CanineCare AI',
                            subtitle: 'Learn about our application',
                            color: blue,
                            background: softBlue,
                            onTap: () => _showAbout(context),
                          ),
                          _SettingItem(
                            icon: Icons.support_agent_rounded,
                            title: 'Help & Support',
                            subtitle: 'Get assistance with the app',
                            color: teal,
                            background: softTeal,
                            onTap: () => _message(context, 'Help & Support'),
                          ),
                          _SettingItem(
                            icon: Icons.star_rounded,
                            title: 'Rate Us',
                            subtitle: 'Share your feedback',
                            color: purple,
                            background: softPurple,
                            onTap: () => _message(context, 'Rate Us'),
                          ),
                        ]),
                      ],

                      const SizedBox(height: 28),
                      _logoutButton(context),
                      const SizedBox(height: 28),
                      _footer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // PROFESSIONAL APP BAR

  Widget _appBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [blue, navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CanineCare AI',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Healthy Dogs ',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _message(context, 'Notifications'),
            icon: const Icon(Icons.notifications_none_rounded, color: navy),
          ),
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE HERO

  Widget _profileHero({
    required String email,
    required String phone,
    required bool isDesktop,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 30 : 21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174A78), Color(0xFF2878D0), Color(0xFF309EAC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -45, child: _circleDecoration(160, 0.07)),
          Positioned(
            right: 70,
            bottom: -80,
            child: _circleDecoration(130, 0.05),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isDesktop ? 88 : 74,
                    height: isDesktop ? 88 : 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.17),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.65),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 29 : 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 28 : 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                size: 14,
                                color: Color(0xFFBDF5E7),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _role,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                padding: EdgeInsets.all(isDesktop ? 19 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _heroInfo(Icons.email_rounded, email),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _heroInfo(Icons.phone_rounded, phone),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _heroInfo(Icons.email_rounded, email),
                          const SizedBox(height: 13),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 13),
                          _heroInfo(Icons.phone_rounded, phone),
                        ],
                      ),
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFBDF5E7),
                    size: 17,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Every dog deserves a healthier life.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleDecoration(double size, double opacity) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _heroInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFBDF5E7), size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // SECTION HEADING

  Widget _sectionHeading(
    String title,
    String subtitle,
    IconData icon,
    Color accent,
  ) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent, size: 23),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // SETTINGS GROUP

  Widget _settingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: items[i].onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: items[i].background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          items[i].icon,
                          color: items[i].color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].title,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              items[i].subtitle,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: muted,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i != items.length - 1)
              const Divider(
                height: 1,
                thickness: 0.8,
                indent: 73,
                endIndent: 15,
                color: border,
              ),
          ],
        ],
      ),
    );
  }

  // LOGOUT

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onLogout ?? () => _message(context, 'Logout'),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD9485F),
          backgroundColor: const Color(0xFFFFF1F3),
          side: const BorderSide(color: Color(0xFFF4CDD3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ABOUT DIALOG

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [blue, navy]),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 37,
            ),
          ),
          title: const Text(
            'CanineCare AI',
            textAlign: TextAlign.center,
            style: TextStyle(color: navy, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'AI-powered canine skin health monitoring designed '
            'to support dog owners in caring for their companions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, height: 1.6),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // FOOTER

  Widget _footer() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 13),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, color: teal, size: 15),
            SizedBox(width: 6),
            Text(
              'Made with care for every dog',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        const Text(
          'CanineCare AI',
          style: TextStyle(
            color: navy,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // PLACEHOLDER ACTION MESSAGE

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$message is not connected yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          showCloseIcon: true,
        ),
      );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });
}
