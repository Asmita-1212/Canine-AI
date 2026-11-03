import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color navy = Color(0xFF142B4A);
  static const Color blue = Color(0xFF3478F6);
  static const Color background = Color(0xFFF5F8FE);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // EXISTING BACKEND LOGIN LOGIC
  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final token = result['access_token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('The server did not return an access token.');
      }

      // Read user details from the login response.
      Map<String, dynamic>? user;

      final userData = result['user'];

      if (userData is Map) {
        user = Map<String, dynamic>.from(userData);
      } else {
        // If login does not include user details, fetch them from FastAPI.
        final profile = await AuthService.getCurrentUser(token);

        if (profile['user'] is Map) {
          user = Map<String, dynamic>.from(profile['user'] as Map);
        } else if (profile.containsKey('role')) {
          user = profile;
        }
      }

      if (user == null) {
        throw Exception('User details were not returned by the server.');
      }

      // Normalize the role, including any accidental whitespace/newline.
      final role = (user['role'] ?? '').toString().trim().toLowerCase();

      debugPrint('LOGIN RESPONSE: $result');
      debugPrint('USER ROLE: "$role"');

      if (role != 'admin' && role != 'user') {
        throw Exception('Invalid or missing role returned by FastAPI: "$role"');
      }

      await _secureStorage.write(key: 'access_token', value: token);

      if (!mounted) return;

      if (role == 'admin') {
        _showMessage('Welcome, Admin!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Admin()),
        );
      } else {
        _showMessage('Login successful! Welcome to CanineCare AI.');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user!)),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOGIN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }

      if (message.contains('SocketException') ||
          message.contains('ClientException') ||
          message.contains('Failed to fetch')) {
        message = 'Cannot connect to the server. Please check your backend.';
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  // RESPONSIVE PAGE LAYOUT
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isDesktop = width >= 1000;
            final isSmallPhone = width < 380;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 12 : (isDesktop ? 32 : 20),
                  vertical: height < 650 ? 12 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1120 : 480),
                  child: isDesktop
                      ? _desktopLayout()
                      : _mobileLayout(isSmallPhone: isSmallPhone),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // DESKTOP: TWO-COLUMN LOGIN CARD
  Widget _desktopLayout() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: _heroSection()),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 38,
                  vertical: 34,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _loginForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MOBILE AND TABLET: STACKED LAYOUT
  Widget _mobileLayout({required bool isSmallPhone}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _mobileHero(isSmallPhone: isSmallPhone),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallPhone ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _loginForm(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _mobileHero({required bool isSmallPhone}) {
    return Column(
      children: [
        _brand(),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: isSmallPhone ? 135 : 175,
            width: double.infinity,
            child: _dogImage(),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Healthy Dog',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Smarter care starts with a healthier skin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
        ),
      ],
    );
  }

  // DESKTOP HERO PANEL
  Widget _heroSection() {
    return Container(
      constraints: const BoxConstraints(minHeight: 620),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102745), Color(0xFF24558A), Color(0xFF3478F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _brand(inverted: true),
          const SizedBox(height: 24),
          const Text(
            'Every paw deserves\na healthier future.',
            style: TextStyle(
              fontSize: 31,
              height: 1.22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'AI-powered canine skin health screening, '
            'designed to help you care with confidence.',
            style: TextStyle(
              color: Color(0xFFDDE9FC),
              height: 1.7,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 230,
              width: double.infinity,
              child: _dogImage(),
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Icon(Icons.favorite_rounded, color: Color(0xFFFFD4D4), size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Built with care for your best friend',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _dogImage() {
    return SizedBox(
      width: 180,
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          'https://images.pexels.com/photos/3752119/pexels-photo-3752119.jpeg',
          width: 180,
          height: 400,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return Container(
              color: const Color(0xFFE5EDFA),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: blue),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFE5EDFA),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_rounded, size: 56, color: navy),
                  SizedBox(height: 8),
                  Text('CanineCare AI', style: TextStyle(color: navy)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // BRAND LOGO AND TITLE
  Widget _brand({bool inverted = false}) {
    final foreground = inverted ? Colors.white : navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: inverted
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFE7EFFF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.pets_rounded,
            color: inverted ? Colors.white : blue,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CanineCare AI',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'SMARTER PET HEALTH',
              style: TextStyle(
                color: inverted ? Colors.white70 : Colors.blueGrey,
                fontSize: 9,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // LOGIN FORM
  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(
              color: navy,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to continue your pet’s health journey.',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // LOGIN / REGISTER SELECTOR
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withValues(alpha: 0.2),
                          blurRadius: 9,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: _openRegister,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _fieldLabel('Email address'),
          const SizedBox(height: 9),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: _inputDecoration(
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Please enter your email';
              }

              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),
          const SizedBox(height: 18),

          _fieldLabel('Password'),
          const SizedBox(height: 9),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            decoration: _inputDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }

              if (value.length < 8) {
                return 'Password must contain at least 8 characters';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),

          // REMEMBER ME AND FORGOT PASSWORD
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 36,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: blue,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showMessage('Password reset is not available yet.');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LOGIN BUTTON
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _isLoading ? null : _login,
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: blue.withValues(alpha: 0.65),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Login to your account',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),

          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE5EAF2))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'CANINECARE AI',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE5EAF2))),
            ],
          ),
          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: Color(0xFF3478F6),
              ),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Your pet’s wellbeing is our priority',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: navy,
      ),
    );
  }

  // REUSABLE INPUT DECORATION
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF7B8CA6), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFAFBFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
