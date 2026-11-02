import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_screen.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  static const Color navy = Color(0xFF163A5F);
  static const Color blue = Color(0xFF2878D0);
  static const Color teal = Color(0xFF14998E);
  static const Color purple = Color(0xFF7759CF);
  static const Color amber = Color(0xFFB97812);
  static const Color muted = Color(0xFF71839A);
  static const Color background = Color(0xFFF5F8FC);
  static const Color border = Color(0xFFE3EAF3);
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await _secureStorage.delete(key: 'access_token');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    }
  }

  int _selectedIndex = 0;

  final List<_AdminMenuItem> _menuItems = const [
    _AdminMenuItem(title: 'Overview', icon: Icons.dashboard_rounded),
    _AdminMenuItem(title: 'Users', icon: Icons.people_alt_rounded),
    _AdminMenuItem(title: 'Dogs', icon: Icons.pets_rounded),
    _AdminMenuItem(title: 'Cases', icon: Icons.folder_copy_rounded),
    _AdminMenuItem(title: 'AI Analysis', icon: Icons.psychology_rounded),
    _AdminMenuItem(title: 'Prevention Tips', icon: Icons.menu_book_rounded),
    _AdminMenuItem(title: 'Settings', icon: Icons.settings_rounded),
  ];

  void _selectMenu(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600;

        return Scaffold(
          backgroundColor: background,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: Colors.white,
                  child: SafeArea(child: _sidebarContent()),
                ),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: navy,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title: const Text(
                    'CanineCare AI',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () =>
                          _showMessage('Notifications UI coming soon'),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
          body: Row(
            children: [
              if (isDesktop) SizedBox(width: 250, child: _sidebarContent()),
              Expanded(
                child: _selectedIndex == 0
                    ? _overview(isTablet)
                    : _placeholderPage(_menuItems[_selectedIndex].title),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFEAF3FF),
                  selectedIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
                  onDestinationSelected: (index) {
                    _selectMenu(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Overview',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: 'Users',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.pets_outlined),
                      selectedIcon: Icon(Icons.pets_rounded),
                      label: 'Dogs',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder_rounded),
                      label: 'Cases',
                    ),
                  ],
                ),
        );
      },
    );
  }

  // --------------------------------------------------
  // SIDEBAR
  // --------------------------------------------------

  Widget _sidebarContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 25),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [blue, teal]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CanineCare AI',
                        style: TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'ADMIN CONSOLE',
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final selected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    color: selected
                        ? const Color(0xFFEAF3FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: () {
                        _selectMenu(index);
                        if (Scaffold.of(context).isDrawerOpen) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected ? blue : muted,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: selected ? navy : muted,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (selected)
                              Container(
                                width: 5,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: blue,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Administrator profile
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE0EBFA),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: navy,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator',
                          style: TextStyle(
                            color: navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Management panel',
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logout button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Material(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: _isLoggingOut ? null : _logout,
                borderRadius: BorderRadius.circular(13),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      if (_isLoggingOut)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      else
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 21,
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _isLoggingOut ? 'Logging out...' : 'Logout',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // OVERVIEW
  // --------------------------------------------------

  Widget _overview(bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? 28 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width >= 900)
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: navy,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showMessage(
                    'Connect notifications to your backend later',
                  ),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: navy,
                    size: 25,
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(Icons.admin_panel_settings_rounded, color: navy),
                ),
              ],
            ),
          if (MediaQuery.of(context).size.width >= 900)
            const SizedBox(height: 22),
          _welcomeBanner(),
          const SizedBox(height: 25),
          const Text(
            'Platform Overview',
            style: TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'A quick look at your pet health platform.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 17),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850
                  ? 4
                  : constraints.maxWidth >= 500
                  ? 2
                  : 2;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: constraints.maxWidth < 360
                    ? 1.05
                    : constraints.maxWidth < 500
                    ? 1.18
                    : 1.35,
                children: [
                  _statCard(
                    title: 'Total Users',
                    value: '3',
                    subtitle: 'Registered accounts',
                    icon: Icons.people_alt_rounded,
                    color: blue,
                    tint: const Color(0xFFEAF3FF),
                  ),
                  _statCard(
                    title: 'Dog Profiles',
                    value: '4',
                    subtitle: 'Registered dogs',
                    icon: Icons.pets_rounded,
                    color: teal,
                    tint: const Color(0xFFE7F7F2),
                  ),
                  _statCard(
                    title: 'Total Cases',
                    value: '4',
                    subtitle: 'Submitted cases',
                    icon: Icons.folder_copy_rounded,
                    color: purple,
                    tint: const Color(0xFFF0EDFF),
                  ),
                  _statCard(
                    title: 'Pending Cases',
                    value: '4',
                    subtitle: 'Awaiting attention',
                    icon: Icons.pending_actions_rounded,
                    color: amber,
                    tint: const Color(0xFFFFF4E2),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 26),
          _sectionHeader(
            'Recent Activity',
            'Example activity for the dashboard',
          ),
          const SizedBox(height: 14),
          _activityCard(
            icon: Icons.person_add_alt_1_rounded,
            color: blue,
            title: 'New user registered',
            subtitle: 'A new account will appear here',
            time: 'Sample',
          ),
          _activityCard(
            icon: Icons.pets_rounded,
            color: teal,
            title: 'New dog profile',
            subtitle: 'A registered dog profile will appear here',
            time: 'Sample',
          ),
          _activityCard(
            icon: Icons.folder_open_rounded,
            color: purple,
            title: 'New case submitted',
            subtitle: 'Review submitted cases here',
            time: 'Sample',
          ),
          const SizedBox(height: 26),
          _sectionHeader('Management Shortcuts', 'Choose a section to explore'),
          const SizedBox(height: 14),
          _shortcut(
            icon: Icons.people_alt_rounded,
            title: 'Manage Users',
            subtitle: 'View and manage registered accounts',
            color: blue,
            onTap: () => _selectMenu(1),
          ),
          _shortcut(
            icon: Icons.pets_rounded,
            title: 'Manage Dogs',
            subtitle: 'Explore dog profiles and their owners',
            color: teal,
            onTap: () => _selectMenu(2),
          ),
          _shortcut(
            icon: Icons.folder_copy_rounded,
            title: 'Manage Cases',
            subtitle: 'Inspect case details and status',
            color: purple,
            onTap: () => _selectMenu(3),
          ),
          _shortcut(
            icon: Icons.psychology_rounded,
            title: 'AI Analysis',
            subtitle: 'Monitor analysis processing',
            color: amber,
            onTap: () => _selectMenu(4),
          ),
          _shortcut(
            icon: Icons.menu_book_rounded,
            title: 'Prevention Tips',
            subtitle: 'Manage educational content',
            color: blue,
            onTap: () => _selectMenu(5),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'CanineCare AI • Admin Console',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, blue, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.pets_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMIN CONTROL CENTER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Welcome back, Admin!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Manage pet profiles, monitor cases, and oversee '
                'your CanineCare AI platform from one place.',
                style: TextStyle(
                  color: Color(0xFFE5F0FC),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _selectMenu(3),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: const Text('Explore Cases'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 9, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
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
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    );
  }

  Widget _activityCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(color: muted, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: muted, size: 23),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PLACEHOLDER PAGES
  // --------------------------------------------------

  Widget _placeholderPage(String title) {
    final item = _menuItems[_selectedIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Icon(item.icon, color: blue, size: 37),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This section is ready for UI development. '
                'We can add its screens and connect your existing '
                'FastAPI backend in the next step.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, height: 1.6, fontSize: 13),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => _selectMenu(0),
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Overview'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;

  const _AdminMenuItem({required this.title, required this.icon});
}
