import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/Follow-ups.dart';
import 'package:frontend/screens/prevenationtips.dart';

import 'add_case_screen.dart';
import 'my_cases_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'symptom_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color navy = Color(0xFF153E68);
  static const Color blue = Color(0xFF2878D0);
  static const Color teal = Color(0xFF159A91);
  static const Color muted = Color(0xFF72849A);
  static const Color background = Color(0xFFF4F8FC);
  static const Color borderColor = Color(0xFFE1EAF3);

  static const String dogAsset = 'assets/images/golden_retriever.png';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  String get _userName {
    final name = (widget.user['full_name'] ?? widget.user['name'] ?? '')
        .toString()
        .trim();

    return name.isEmpty ? 'Farmer' : name.split(' ').first;
  }

  // NAVIGATION

  Future<void> _openPage(Widget page, {required int selectedIndex}) async {
    setState(() => _selectedIndex = selectedIndex);

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
  }

  void _openAddCase() {
    _openPage(const AddCaseScreen(), selectedIndex: 2);
  }

  void _openCases() {
    _openPage(const MyCasesScreen(), selectedIndex: 1);
  }

  void _followups() {
    _openPage(const Followups(), selectedIndex: 3);
  }

  void _openProfile() {
    _openPage(
      ProfileScreen(user: widget.user, onLogout: _logout),
      selectedIndex: 4,
    );
  }
  void _openSymptomChat() {
  _openPage(
    const SymptomChatScreen(),
    selectedIndex: 0,
  );
}
  void _selectTab(int index) {
    switch (index) {
      case 0:
        _openSymptomChat();
        break;
      case 1:
        _openCases();
        break;
      case 2:
        _openAddCase();
        break;
      case 3:
        _followups();
        break;
      case 4:
        _openProfile();
        break;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon.'),
          backgroundColor: navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  // MAIN DASHBOARD

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 900;
        final isTablet = width >= 600 && width < 900;

        return Scaffold(
          backgroundColor: background,

          // This drawer slides in from the left.
          drawer: _buildDrawer(),

          // Hamburger menu works on desktop, tablet and mobile.
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: navy,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'CanineCare AI',
              style: TextStyle(
                color: navy,
                fontSize: isDesktop ? 22 : 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: Builder(
              builder: (drawerContext) {
                return IconButton(
                  tooltip: 'Open navigation menu',
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  onPressed: () {
                    Scaffold.of(drawerContext).openDrawer();
                  },
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  tooltip: 'My Profile',
                  onPressed: _openProfile,
                  icon: const Icon(Icons.person_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE5F1FF),
                    foregroundColor: navy,
                  ),
                ),
              ),
            ],
          ),

          // Responsive, scrollable dashboard content.
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 18,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _welcomeBanner(isDesktop),
                    const SizedBox(height: 28),

                    const Text(
                      'Explore Services',
                      style: TextStyle(
                        color: navy,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _featureGrid(isDesktop: isDesktop, isTablet: isTablet),

                    const SizedBox(height: 22),
                    _preventionCard(),
                    const SizedBox(height: 16),
                    _footerBanner(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation is used on smaller screens.
          bottomNavigationBar: isDesktop ? null : _bottomNavigation(),
        );
      },
    );
  }

  // SLIDING DRAWER

  Widget _buildDrawer() {
    return Drawer(
      width: 285,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 28, 18, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEAF5FF), Color(0xFFDDEEFF)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 34,
                      color: blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CanineCare AI',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Welcome, $_userName!',
                    style: const TextStyle(fontSize: 14, color: muted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _drawerItem(icon: Icons.home_rounded, label: 'Dashboard', index: 0),
            _drawerItem(
              icon: Icons.folder_open_rounded,
              label: 'My Cases',
              index: 1,
            ),
            _drawerItem(
              icon: Icons.camera_alt_rounded,
              label: 'New Diagnosis',
              index: 2,
            ),
            _drawerItem(
              icon: Icons.calendar_month_rounded,
              label: 'Follow-ups',
              index: 3,
            ),
            _drawerItem(
              icon: Icons.person_rounded,
              label: 'My Profile',
              index: 4,
            ),

            const Spacer(),
            const Divider(color: borderColor),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 26),
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _isLoggingOut ? null : _logout,
              trailing: _isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFE8F3FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: ListTile(
          leading: Icon(icon, color: selected ? blue : muted),
          title: Text(
            label,
            style: TextStyle(
              color: selected ? blue : navy,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          trailing: selected
              ? Container(
                  width: 4,
                  height: 26,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          onTap: () {
            // Close the drawer before navigating.
            Navigator.pop(context);
            _selectTab(index);
          },
        ),
      ),
    );
  }

  // WELCOME BANNER

  Widget _welcomeBanner(bool isDesktop) {
    final bannerHeight = isDesktop ? 230.0 : 195.0;
    final imageWidth = isDesktop ? 210.0 : 145.0;

    return Container(
      height: bannerHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5FF), Color(0xFFDDEEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 400;
          final dogWidth = compact ? 105.0 : imageWidth;

          return Stack(
            children: [
              Positioned(
                right: -35,
                bottom: -45,
                child: Container(
                  width: 220,
                  height: 210,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFE5FF).withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 20,
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: blue.withOpacity(0.5),
                  size: 25,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: dogWidth,
                height: bannerHeight - 5,
                child: Image.asset(
                  dogAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.pets_rounded,
                      color: blue,
                      size: 80,
                    );
                  },
                ),
              ),
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                right: dogWidth + 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $_userName!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: navy,
                        fontSize: isDesktop ? 30 : 23,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Take care of your dog’s health with '
                      'AI-powered assistance.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: isDesktop ? 15 : 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // RESPONSIVE FEATURE CARDS

  Widget _featureGrid({required bool isDesktop, required bool isTablet}) {
    final features = <_FeatureData>[
      _FeatureData(
        icon: Icons.camera_alt_rounded,
        title: 'New Diagnosis',
        description: 'Upload image/video and get AI analysis.',
        cardColor: const Color(0xFFE8F3FF),
        iconColor: blue,
        onTap: _openAddCase,
      ),
      _FeatureData(
        icon: Icons.chat_bubble_rounded,
        title: 'AI Chatbot',
        description: 'Get answers about your dog’s symptoms.',
        cardColor: const Color(0xFFEAF8F2),
        iconColor: teal,
        onTap: _openSymptomChat,
      ),
      _FeatureData(
        icon: Icons.assignment_rounded,
        title: 'My Cases',
        description: 'View your past cases and results.',
        cardColor: const Color(0xFFF0EDFF),
        iconColor: const Color(0xFF7356D8),
        onTap: _openCases,
      ),
      _FeatureData(
        icon: Icons.calendar_month_rounded,
        title: 'Follow-ups',
        description: 'Track recovery progress and reminders.',
        cardColor: const Color(0xFFFFF3E6),
        iconColor: const Color(0xFFE99A43),
        onTap: _followups,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isDesktop ? 4 : 2;
        const gap = 16.0;

        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: features.map((feature) {
            return SizedBox(width: cardWidth, child: _featureCard(feature));
          }).toList(),
        );
      },
    );
  }

  Widget _featureCard(_FeatureData feature) {
    return Material(
      color: feature.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 175),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: feature.iconColor.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: feature.iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(feature.icon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: feature.iconColor,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                feature.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feature.description,
                style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preventionCard() {
    return Material(
      color: const Color(0xFFE8F3FF),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Prevenationtips()),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDCEBFA)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prevention & Care Tips',
                      style: TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Learn how to keep your dog healthy.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: blue, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // FOOTER

  Widget _footerBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8F0E9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets_rounded, size: 38, color: teal),
          Container(
            height: 44,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFFB8DED5),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthy Dogs',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
          Icon(Icons.eco_rounded, size: 32, color: teal.withOpacity(0.5)),
        ],
      ),
    );
  }

  // MOBILE BOTTOM NAVIGATION

  Widget _bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor, width: 0.7)),
        ),
        child: Row(
          children: [
            _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _navItem(icon: Icons.folder_open_rounded, label: 'Cases', index: 1),
            Expanded(
              child: Center(
                child: Material(
                  color: blue,
                  shape: const CircleBorder(),
                  elevation: 5,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _openAddCase,
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _navItem(
              icon: Icons.calendar_month_rounded,
              label: 'Follow-ups',
              index: 3,
            ),
            _navItem(icon: Icons.person_rounded, label: 'Profile', index: 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 23, color: selected ? blue : muted),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? blue : muted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 22 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color cardColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.cardColor,
    required this.iconColor,
    required this.onTap,
  });
}
