import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'add_case_screen.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  // CanineCare AI theme
  static const Color navy = Color(0xFF163A5F);
  static const Color blue = Color(0xFF2878D0);
  static const Color teal = Color(0xFF14998E);
  static const Color purple = Color(0xFF7759CF);
  static const Color amber = Color(0xFFB97812);
  static const Color muted = Color(0xFF71839A);
  static const Color background = Color(0xFFF5F8FC);
  static const Color cardBorder = Color(0xFFE3EAF3);
  static const Color softBlue = Color(0xFFEDF5FF);
  static const Color chipBlue = Color(0xFFE7F1FF);
  static const Color divider = Color(0xFFE8EDF4);
  static const Color mintBackground = Color(0xFFE7F7F2);
  static const Color lavenderBackground = Color(0xFFF0EDFF);
  static const Color amberBackground = Color(0xFFFFF4E2);

  // Keep this URL consistent with your backend setup.
  static const String baseUrl = 'http://127.0.0.1:8000';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = true;
  bool _showSearch = false;
  String? _error;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Ongoing',
    'Completed',
    'Follow-up',
  ];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // API
  // --------------------------------------------------

  Future<void> _loadCases() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Please log in to view your cases.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/cases/?limit=100&skip=0'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Your session expired. Please log in again.');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load cases (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response received from the server.');
      }

      final rawCases = decoded['cases'] as List<dynamic>? ?? [];

      final loadedCases = rawCases
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _cases = loadedCases;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // --------------------------------------------------
  // CASE HELPERS
  // --------------------------------------------------

  Map<String, dynamic> _dogOf(Map<String, dynamic> item) {
    final dog = item['dog'];

    if (dog is Map) {
      return Map<String, dynamic>.from(dog);
    }

    return {};
  }

  String _statusOf(Map<String, dynamic> item) {
    return (item['status'] ?? 'pending')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('_', '-');
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'ongoing':
      case 'in-progress':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'follow-up':
      case 'followup':
        return 'Follow-up';
      default:
        if (status.isEmpty) return 'Pending';
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  bool _matchesFilter(String status, String filter) {
    switch (filter) {
      case 'All':
        return true;
      case 'Pending':
        return status == 'pending';
      case 'Ongoing':
        return status == 'ongoing' || status == 'in-progress';
      case 'Completed':
        return status == 'completed';
      case 'Follow-up':
        return status == 'follow-up' || status == 'followup';
      default:
        return false;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return amber;
      case 'ongoing':
      case 'in-progress':
        return teal;
      case 'completed':
        return blue;
      case 'follow-up':
      case 'followup':
        return purple;
      default:
        return muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'pending':
        return amberBackground;
      case 'ongoing':
      case 'in-progress':
        return mintBackground;
      case 'completed':
        return chipBlue;
      case 'follow-up':
      case 'followup':
        return lavenderBackground;
      default:
        return const Color(0xFFEDF1F6);
    }
  }

  List<Map<String, dynamic>> get _filteredCases {
    final query = _searchController.text.trim().toLowerCase();

    return _cases.where((item) {
      final dog = _dogOf(item);
      final name = (dog['name'] ?? '').toString().toLowerCase();
      final id = (item['case_number'] ?? item['id'] ?? '')
          .toString()
          .toLowerCase();

      final matchesSearch =
          query.isEmpty || name.contains(query) || id.contains(query);

      return matchesSearch && _matchesFilter(_statusOf(item), _selectedFilter);
    }).toList();
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return 'Date unavailable';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _ageLabel(dynamic age) {
    if (age == null || age.toString().trim().isEmpty) {
      return 'Age unavailable';
    }

    final parsed = double.tryParse(age.toString());
    if (parsed == null) return age.toString();

    final value = parsed == parsed.roundToDouble()
        ? parsed.toInt().toString()
        : parsed.toString();

    return '$value ${parsed == 1 ? 'year' : 'years'}';
  }

  // --------------------------------------------------
  // MEDIA
  // --------------------------------------------------

  String? _mediaUrl(Map<String, dynamic> item) {
    final media = item['media'];

    if (media is! Map || media['url'] == null) return null;

    final path = media['url'].toString().trim();
    if (path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  Future<Map<String, String>> _imageHeaders() async {
    final token = await _storage.read(key: 'access_token');

    if (token == null || token.isEmpty) return {};

    return {'Authorization': 'Bearer $token'};
  }

  bool _isVideo(Map<String, dynamic> item) {
    final media = item['media'];
    if (media is! Map) return false;

    final type = (media['media_type'] ?? '').toString().toLowerCase();
    final filename =
        (media['original_filename'] ??
                media['stored_filename'] ??
                media['url'] ??
                '')
            .toString()
            .toLowerCase();

    if (type.startsWith('video/') || type == 'video') return true;
    if (type.startsWith('image/') || type == 'image') return false;

    return ['.mp4', '.mov', '.webm', '.avi', '.m4v'].any(filename.endsWith);
  }

  Widget _mediaPlaceholder({
    required IconData icon,
    required String label,
    double size = 110,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFDDEBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: blue),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dogImage(Map<String, dynamic> item, {double size = 110}) {
    final url = _mediaUrl(item);

    if (url == null) {
      return _mediaPlaceholder(
        icon: Icons.pets_rounded,
        label: 'No photo',
        size: size,
      );
    }

    if (_isVideo(item)) {
      return _mediaPlaceholder(
        icon: Icons.play_circle_fill_rounded,
        label: 'Video',
        size: size,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: size,
        height: size,
        child: FutureBuilder<Map<String, String>>(
          future: _imageHeaders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _mediaPlaceholder(
                icon: Icons.broken_image_outlined,
                label: 'Image unavailable',
                size: size,
              );
            }

            if (!snapshot.hasData) {
              return Container(
                color: softBlue,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(strokeWidth: 2, color: blue),
                ),
              );
            }

            return Image.network(
              url,
              headers: snapshot.data!,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => _mediaPlaceholder(
                icon: Icons.broken_image_outlined,
                label: 'Load failed',
                size: size,
              ),
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ARROW-STYLE APP BAR
  // --------------------------------------------------

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _headerAction(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Go back',
            onTap: () => Navigator.of(context).maybePop(),
            color: navy,
            fill: softBlue,
          ),
          const SizedBox(width: 10),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [blue, teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CanineCare AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your dog’s health, in one place',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          _headerAction(
            icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
            tooltip: _showSearch ? 'Close search' : 'Search cases',
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.clear();
              });
            },
            color: navy,
          ),
          const SizedBox(width: 3),
          _headerAction(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh cases',
            onTap: _isLoading ? null : _loadCases,
            color: teal,
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    required Color color,
    Color? fill,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: fill ?? Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 40,
            height: 43,
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // INTRODUCTION
  // --------------------------------------------------

  Widget _intro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFE8F8F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFDCEAF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, color: teal, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'PET HEALTH DASHBOARD',
                        style: TextStyle(
                          color: navy,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'My Cases',
                  style: TextStyle(
                    color: navy,
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'View and manage your dog’s health cases '
                  'and AI analysis results.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.55),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: teal, size: 17),
                    const SizedBox(width: 6),
                    Text(
                      '${_cases.length} ${_cases.length == 1 ? 'case' : 'cases'} recorded',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [blue, teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: blue.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SEARCH
  // --------------------------------------------------

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search dog name or case ID',
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: blue),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _searchController.clear());
          },
          icon: const Icon(Icons.close_rounded, color: muted),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // FILTER CHIPS
  // --------------------------------------------------

  Widget _filterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: navy,
            side: BorderSide(color: selected ? navy : cardBorder),
            labelStyle: TextStyle(
              color: selected ? Colors.white : navy,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // REUSABLE STATUS AND INFO WIDGETS
  // --------------------------------------------------

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        _statusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, {Color iconColor = muted}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _diagnosisContent(String? diagnosis, dynamic confidence) {
    final hasDiagnosis = diagnosis != null && diagnosis.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Possible condition',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          hasDiagnosis ? diagnosis : 'Analysis pending',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        if (confidence != null)
          Text(
            'Confidence: $confidence%',
            style: const TextStyle(
              color: teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          const Text(
            'Awaiting results',
            style: TextStyle(color: muted, fontSize: 11),
          ),
      ],
    );
  }

  // --------------------------------------------------
  // CASE CARD
  // --------------------------------------------------

  Widget _caseCard(Map<String, dynamic> item) {
    final dog = _dogOf(item);
    final name = (dog['name'] ?? 'Unnamed dog').toString();
    final gender = (dog['gender'] ?? 'Unknown').toString();
    final breed = (dog['breed'] ?? '').toString();
    final status = _statusOf(item);
    final caseNumber = (item['case_number'] ?? 'CASE${item['id'] ?? ''}')
        .toString();
    final diagnosis = item['diagnosis']?.toString();
    final confidence = item['confidence'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _openCase(item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: compact
                  ? _compactCaseContent(
                      item: item,
                      dog: dog,
                      name: name,
                      gender: gender,
                      breed: breed,
                      status: status,
                      caseNumber: caseNumber,
                      diagnosis: diagnosis,
                      confidence: confidence,
                    )
                  : _wideCaseContent(
                      item: item,
                      dog: dog,
                      name: name,
                      gender: gender,
                      breed: breed,
                      status: status,
                      caseNumber: caseNumber,
                      diagnosis: diagnosis,
                      confidence: confidence,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _compactCaseContent({
    required Map<String, dynamic> item,
    required Map<String, dynamic> dog,
    required String name,
    required String gender,
    required String breed,
    required String status,
    required String caseNumber,
    required String? diagnosis,
    required dynamic confidence,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dogImage(item, size: 100),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoLine(
                    gender.toLowerCase() == 'female'
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    '$gender • ${_ageLabel(dog['age'])}',
                  ),
                  if (breed.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _infoLine(Icons.pets_rounded, breed),
                  ],
                  const SizedBox(height: 6),
                  _infoLine(
                    Icons.calendar_month_rounded,
                    _formatDate(item['created_at']),
                    iconColor: teal,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        const Divider(height: 1, color: divider),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ID: $caseNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _statusPill(status),
          ],
        ),
        const SizedBox(height: 13),
        _diagnosisContent(diagnosis, confidence),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.arrow_forward_rounded, color: blue, size: 20),
        ),
      ],
    );
  }

  Widget _wideCaseContent({
    required Map<String, dynamic> item,
    required Map<String, dynamic> dog,
    required String name,
    required String gender,
    required String breed,
    required String status,
    required String caseNumber,
    required String? diagnosis,
    required dynamic confidence,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dogImage(item, size: 120),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              _infoLine(
                gender.toLowerCase() == 'female'
                    ? Icons.female_rounded
                    : Icons.male_rounded,
                '$gender • ${_ageLabel(dog['age'])}',
              ),
              if (breed.isNotEmpty) ...[
                const SizedBox(height: 6),
                _infoLine(Icons.pets_rounded, breed),
              ],
              const SizedBox(height: 7),
              _infoLine(
                Icons.calendar_month_rounded,
                _formatDate(item['created_at']),
                iconColor: teal,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ID: $caseNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 135, color: divider),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusPill(status),
              const SizedBox(height: 14),
              _diagnosisContent(diagnosis, confidence),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, color: blue, size: 21),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // CASE DETAILS
  // --------------------------------------------------

  void _openCase(Map<String, dynamic> item) {
    final dog = _dogOf(item);
    final status = _statusOf(item);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cardBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (dog['name'] ?? 'Case details').toString(),
                          style: const TextStyle(
                            color: navy,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _statusPill(status),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _detailRow(
                    'Case ID',
                    (item['case_number'] ?? item['id'] ?? '-').toString(),
                  ),
                  _detailRow(
                    'Breed',
                    (dog['breed'] ?? 'Not specified').toString(),
                  ),
                  _detailRow('Age', _ageLabel(dog['age'])),
                  _detailRow('Gender', (dog['gender'] ?? '-').toString()),
                  _detailRow('Created', _formatDate(item['created_at'])),
                  _detailRow('Status', _statusLabel(status)),
                  _detailRow(
                    'Diagnosis',
                    (item['diagnosis'] ?? 'Analysis pending').toString(),
                  ),
                  if (item['confidence'] != null)
                    _detailRow('Confidence', '${item['confidence']}%'),
                  const SizedBox(height: 18),
                  const Text(
                    'Additional notes',
                    style: TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Text(
                      (item['notes'] ?? '').toString().trim().isEmpty
                          ? 'No additional notes.'
                          : item['notes'].toString(),
                      style: const TextStyle(color: muted, height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Close details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: const TextStyle(color: muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: navy, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY AND ERROR STATES
  // --------------------------------------------------

  Widget _emptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasFilter = _selectedFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 25),
        child: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE7F1FF), Color(0xFFD7E9FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, color: blue, size: 49),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch || hasFilter ? 'No matching cases' : 'No cases yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Your submitted dog cases will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadCases,
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                side: const BorderSide(color: blue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 55, color: muted),
          const SizedBox(height: 15),
          Text(
            _error ?? 'Unable to load cases.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: navy, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _loadCases,
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ADD CASE
  // --------------------------------------------------

  Future<void> _addCase() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddCaseScreen()));

    if (mounted) {
      await _loadCases();
    }
  }

  // --------------------------------------------------
  // MAIN SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cases = _filteredCases;

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add new case',
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _addCase,
        icon: const Icon(Icons.add_rounded, size: 25),
        label: const Text(
          'Add Case',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCases,
          color: blue,
          backgroundColor: Colors.white,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _header(),
              const SizedBox(height: 20),
              _intro(),
              if (_showSearch) ...[const SizedBox(height: 18), _searchField()],
              const SizedBox(height: 22),
              _filterBar(),
              const SizedBox(height: 22),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: blue)),
                )
              else if (_error != null)
                _errorState()
              else if (cases.isEmpty)
                _emptyState()
              else ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your health cases',
                        style: TextStyle(
                          color: navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: chipBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cases.length} ${cases.length == 1 ? 'case' : 'cases'}',
                        style: const TextStyle(
                          color: blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...cases.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _caseCard(item),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Together for healthier dogs 💚',
                  style: TextStyle(
                    color: teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
