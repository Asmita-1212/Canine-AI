import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  static const navy = Color(0xFF15508D);
  static const blue = Color(0xFF347CE0);
  static const muted = Color(0xFF8295B0);
  static const paleBlue = Color(0xFFEAF5FF);
  static const pageBackground = Color(0xFFF5F8FC);
  static const borderColor = Color(0xFFDCE8F5);
  static const purple = Color(0xFF7858D5);

  // Existing backend configuration.
  static const String _baseUrl = 'http://127.0.0.1:8000';

  final _formKey = GlobalKey<FormState>();
  final _dogNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _gender;
  PlatformFile? _selectedFile;
  String? _selectedType;
  bool _isLoading = false;

  @override
  void dispose() {
    _dogNameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // FILE PICKING — existing functionality.
  Future<void> _pickFile(String type) async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: type == 'image' ? FileType.image : FileType.video,
      );

      if (file == null || !mounted) return;

      final int fileSize = await file.length() ?? 0;
      final int maxSize = type == 'image' ? 5 * 1024 * 1024 : 50 * 1024 * 1024;

      if (fileSize > maxSize) {
        _showMessage(
          type == 'image'
              ? 'Image size must be less than 5 MB.'
              : 'Video size must be less than 50 MB.',
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedType = type;
      });

      _showMessage(
        '${type == 'image' ? 'Image' : 'Video'} selected successfully.',
      );
    } catch (error) {
      _showMessage('File selection failed: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _next() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      _showMessage('Please select your dog’s gender.');
      return;
    }

    if (_selectedFile == null) {
      _showMessage('Please upload an image or video.');
      return;
    }

    await _submitCase();
  }

  // API SUBMISSION — endpoint and request fields preserved.
  Future<void> _submitCase() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final token = await _secureStorage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again. Your session has expired.');
      }

      final file = _selectedFile!;
      final bytes = await file.xFile.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('The selected file is empty. Please select it again.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/cases/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['dog_name'] = _dogNameController.text.trim();
      request.fields['age'] = _ageController.text.trim();
      request.fields['gender'] = _gender!;
      request.fields['breed'] = _breedController.text.trim();
      request.fields['notes'] = _notesController.text.trim();

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'The server returned an unexpected response '
          '(HTTP ${response.statusCode}).',
        );
      }

      if (response.statusCode == 201) {
        if (!mounted) return;
        _showMessage('Case submitted successfully!');
      } else {
        final detail = data['detail'] ?? 'Failed to submit case.';
        throw Exception(detail.toString());
      }
    } catch (error) {
      if (!mounted) return;

      var message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }

      if (message.contains('SocketException') ||
          message.contains('ClientException') ||
          message.contains('Failed to fetch')) {
        message =
            'Cannot connect to the backend. Make sure FastAPI is running.';
      }

      _showMessage(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // CONSISTENT INPUT STYLING.
  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      prefixIcon: Icon(icon, color: navy, size: 21),
      filled: true,
      fillColor: const Color(0xFFFCFDFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // TOP BRAND BAR.
  Widget _brand() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: navy, size: 27),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F1FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.pets_rounded, color: blue, size: 28),
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
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Healthy Dogs  •  Happier Farmers',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.pets_rounded, color: Color(0xFFB4DFEE), size: 30),
      ],
    );
  }

  // RESPONSIVE INTRO — no fixed-height header.
  Widget _intro() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;
        final imageSize = compact ? 70.0 : 108.0;

        return Container(
          margin: const EdgeInsets.only(top: 22, bottom: 22),
          padding: EdgeInsets.all(compact ? 16 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF5FF), Color(0xFFDDEEFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'AI-POWERED PET HEALTH',
                        style: TextStyle(
                          color: blue,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Add New Case',
                      style: TextStyle(
                        color: navy,
                        fontSize: compact ? 24 : 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your dog’s details and upload an image '
                      'or video for AI analysis.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: imageSize,
                height: imageSize,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color(0xFFD3E8FF),
                  shape: BoxShape.circle,
                ),
                child: _dogIllustration(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dogIllustration() {
    return Image.network(
      'https://images.unsplash.com/photo-1552053831-71594a27632d'
      '?auto=format&fit=crop&w=350&q=80',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.pets_rounded, size: 58, color: blue),
    );
  }

  // REUSABLE NUMBERED SECTION CARD.
  Widget _section({
    required String number,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            color: paleBlue,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: navy,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  Widget _label(String text, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: text),
            if (!optional)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
            if (optional)
              const TextSpan(
                text: ' (optional)',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // DOG DETAILS — 2 columns on wide screens, 1 on narrow screens.
  Widget _dogDetails() {
    return _section(
      number: '1',
      title: 'Dog Details',
      subtitle: 'Tell us a little about your pet',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 560;
          final fieldWidth = twoColumns
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Dog Name'),
                    TextFormField(
                      controller: _dogNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration(
                        hint: 'Enter dog name',
                        icon: Icons.pets_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter dog name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Age (in years)'),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoration(
                        hint: 'Enter age',
                        icon: Icons.cake_outlined,
                      ),
                      validator: (value) {
                        final age = double.tryParse(value ?? '');
                        if (age == null || age < 0 || age > 100) {
                          return 'Enter a valid age';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Gender'),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      isExpanded: true,
                      decoration: _decoration(
                        hint: 'Select gender',
                        icon: Icons.wc_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() => _gender = value);
                            },
                      validator: (value) =>
                          value == null ? 'Select gender' : null,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Breed', optional: true),
                    TextFormField(
                      controller: _breedController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration(
                        hint: 'Enter breed',
                        icon: Icons.pets_outlined,
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

  // IMAGE / VIDEO UPLOAD CARD.
  Widget _uploadOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color background,
    required String type,
  }) {
    final selected = _selectedType == type;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isLoading ? null : () => _pickFile(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : color.withOpacity(0.22),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
              if (selected && _selectedFile != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadSection() {
    return _section(
      number: '2',
      title: 'Upload Image ',
      subtitle: 'Choose clear media for AI analysis',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 560;
          final width = twoColumns
              ? (constraints.maxWidth - 14) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: width,
                child: _uploadOption(
                  title: 'Upload Image',
                  subtitle: 'JPG, PNG (Max 5 MB)',
                  icon: Icons.image_rounded,
                  color: blue,
                  background: const Color(0xFFEDF6FF),
                  type: 'image',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // OPTIONAL NOTES.
  Widget _notesSection() {
    return _section(
      number: '3',
      title: 'Additional Information',
      subtitle: 'Symptoms or previous treatment (optional)',
      child: TextFormField(
        controller: _notesController,
        maxLength: 500,
        maxLines: 4,
        minLines: 3,
        decoration: InputDecoration(
          hintText:
              'Describe symptoms, when they started, previous treatment, '
              'or the location of the affected area...',
          hintStyle: const TextStyle(color: muted, fontSize: 13),
          alignLabelWithHint: true,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 65),
            child: Icon(Icons.description_outlined, color: muted),
          ),
          filled: true,
          fillColor: const Color(0xFFFCFDFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  // COMPLETE RESPONSIVE PAGE.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1000;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: isDesktop ? 20 : 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1250),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _brand(),
                        _intro(),
                        _dogDetails(),
                        _uploadSection(),
                        _notesSection(),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _next,
                            style: FilledButton.styleFrom(
                              backgroundColor: blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: blue.withOpacity(0.6),
                              elevation: 0,
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
                                        'Continue to AI Analysis',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 17,
                              color: muted,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                'Together for healthier dogs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
