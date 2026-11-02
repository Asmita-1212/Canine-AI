import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color navy = Color(0xFF142B4A);
  static const Color blue = Color(0xFF3478F6);
  static const Color background = Color(0xFFF5F8FE);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _register() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showMessage('Please accept the Terms and Privacy Policy.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final message =
          result['message'] as String? ?? 'Registration successful!';

      _showMessage(message);

      // Return to the login screen after successful registration.
      Navigator.pop(context);
    } catch (error) {
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

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7B8CA6)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFAFBFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: navy,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _brand({bool inverted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: inverted
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFE7EFFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.pets_rounded,
            color: inverted ? Colors.white : blue,
            size: 27,
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CanineCare AI',
              style: TextStyle(
                color: inverted ? Colors.white : navy,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              'SMARTER PET HEALTH',
              style: TextStyle(
                color: inverted ? Colors.white70 : Colors.blueGrey,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dogImage() {
    return Image.network(
      'https://images.pexels.com/photos/3752119/pexels-photo-3752119.jpeg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(child: CircularProgressIndicator(color: blue));
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE7EFFF),
          alignment: Alignment.center,
          child: const Icon(Icons.pets_rounded, size: 60, color: navy),
        );
      },
    );
  }

  Widget _heroSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102745), Color(0xFF24558A), Color(0xFF3478F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _brand(inverted: true),
          const SizedBox(height: 48),
          const Text(
            'Begin a healthier\njourney for your dog.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Create your account to explore AI-assisted '
            'canine skin health screening and care.',
            style: TextStyle(
              color: Color(0xFFDDE9FC),
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
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
                  'Better insights. More confident pet care.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create account',
            style: TextStyle(
              color: navy,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join CanineCare AI and put your pet first.',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          // Login / Register selector
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: _isLoading ? null : () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Text(
                      'Register',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),

          _label('Full name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _decoration(
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              final name = value?.trim() ?? '';

              if (name.isEmpty) {
                return 'Please enter your full name';
              }

              if (name.length < 2) {
                return 'Name must contain at least 2 characters';
              }

              if (name.length > 100) {
                return 'Name cannot exceed 100 characters';
              }

              return null;
            },
          ),
          const SizedBox(height: 15),

          _label('Email address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: _decoration(
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
          const SizedBox(height: 15),

          _label('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            enabled: !_isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _decoration(
              hint: 'Create a strong password',
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
                return 'Please create a password';
              }

              if (value.length < 8) {
                return 'Use at least 8 characters';
              }

              if (value.length > 128) {
                return 'Password cannot exceed 128 characters';
              }

              if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                  !RegExp(r'[0-9]').hasMatch(value)) {
                return 'Include at least one letter and one number';
              }

              return null;
            },
          ),
          const SizedBox(height: 15),

          _label('Confirm password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_isLoading,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _register(),
            decoration: _decoration(
              hint: 'Re-enter your password',
              icon: Icons.verified_user_outlined,
              suffix: IconButton(
                tooltip: _obscureConfirmPassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }

              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }

              return null;
            },
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Checkbox(
                  value: _acceptTerms,
                  activeColor: blue,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _isLoading ? null : _register,
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
                        Text(
                          'Create my account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: blue),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Your information deserves secure handling',
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

  Widget _desktopLayout(double width) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: width * 0.47, child: _heroSection()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
              child: _registrationForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brand(),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 165,
            width: double.infinity,
            child: _dogImage(),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
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
          child: _registrationForm(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 18,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: isDesktop
                      ? _desktopLayout(
                          constraints.maxWidth.clamp(900, 1120).toDouble(),
                        )
                      : _mobileLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
