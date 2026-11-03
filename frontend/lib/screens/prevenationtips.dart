import 'package:flutter/material.dart';

class Prevenationtips extends StatefulWidget {
  const Prevenationtips({super.key});

  @override
  State<Prevenationtips> createState() => _PrevenationtipsState();
}

class _PrevenationtipsState extends State<Prevenationtips> {
  static const Color navy = Color(0xFF163A5F);
  static const Color blue = Color(0xFF2878D0);
  static const Color teal = Color(0xFF14998E);
  static const Color muted = Color(0xFF71839A);
  static const Color background = Color(0xFFF5F8FC);
  static const Color border = Color(0xFFE3EAF3);

  final Set<int> _completedTasks = {};

  final List<Map<String, dynamic>> _dailyTasks = [
    {
      'title': 'Check your dog’s skin',
      'subtitle': 'Look for redness, sores, bumps or unusual hair loss.',
      'icon': Icons.search_rounded,
    },
    {
      'title': 'Brush the coat',
      'subtitle': 'Use a suitable brush to remove loose hair and dirt.',
      'icon': Icons.brush_rounded,
    },
    {
      'title': 'Check paws and ears',
      'subtitle': 'Look for irritation, swelling or unusual discharge.',
      'icon': Icons.pets_rounded,
    },
    {
      'title': 'Refresh drinking water',
      'subtitle': 'Provide clean, fresh water throughout the day.',
      'icon': Icons.water_drop_rounded,
    },
  ];

  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Skin & Coat Care',
      'subtitle': 'Brushing, bathing and healthy skin habits',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF2878D0),
      'background': Color(0xFFEAF3FF),
      'details': [
        'Brush your dog regularly using a brush suitable for its coat.',
        'Use dog-specific shampoo when bathing.',
        'Dry the coat thoroughly, especially skin folds and damp areas.',
        'Avoid human shampoos and harsh skin products.',
        'Check for persistent itching, redness, sores or hair loss.',
      ],
    },
    {
      'title': 'Nutrition & Hydration',
      'subtitle': 'Support skin health with balanced nutrition',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFF14998E),
      'background': Color(0xFFE7F7F2),
      'details': [
        'Feed a complete and balanced diet appropriate for your dog.',
        'Keep clean drinking water available.',
        'Introduce dietary changes gradually.',
        'Do not give supplements without checking with your veterinarian.',
        'Discuss suspected food allergies with your veterinarian.',
      ],
    },
    {
      'title': 'Flea & Tick Prevention',
      'subtitle': 'Help protect your dog from parasites',
      'icon': Icons.health_and_safety_rounded,
      'color': Color(0xFF7759CF),
      'background': Color(0xFFF0EDFF),
      'details': [
        'Check the coat and skin for fleas and ticks regularly.',
        'Use veterinarian-recommended parasite prevention.',
        'Follow the product instructions and correct weight-based dose.',
        'Wash bedding and clean your dog’s resting area regularly.',
        'Never use a product intended for another species unless your vet confirms it is safe.',
      ],
    },
    {
      'title': 'Bathing & Hygiene',
      'subtitle': 'Keep your dog clean without irritating its skin',
      'icon': Icons.bathtub_rounded,
      'color': Color(0xFFB97812),
      'background': Color(0xFFFFF4E2),
      'details': [
        'Choose a gentle shampoo formulated for dogs.',
        'Bathe as needed based on coat type and veterinary advice.',
        'Rinse thoroughly to remove shampoo residue.',
        'Keep ears dry and avoid putting products inside the ear canal.',
        'Ask your veterinarian about special bathing needs for skin conditions.',
      ],
    },
  ];

  void _openTopic(Map<String, dynamic> topic) {
    final details = topic['details'] as List<String>;
    final color = topic['color'] as Color;
    final backgroundColor = topic['background'] as Color;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
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
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Icon(
                      topic['icon'] as IconData,
                      color: color,
                      size: 31,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    topic['title'] as String,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic['subtitle'] as String,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...details.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 27,
                            height: 27,
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: color,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 14,
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Got it'),
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

  Widget _appBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: navy,
                size: 23,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [blue, teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prevention & Care',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Your dog’s wellness guide',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163A5F), Color(0xFF2878D0), Color(0xFF14998E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -7,
            top: 0,
            child: Icon(
              Icons.pets_rounded,
              size: 112,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'CANINECARE AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Healthy Skin,Happy Dog!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                'Small daily habits can make a big difference '
                'to your dog’s comfort and wellbeing.',
                style: TextStyle(
                  color: Color(0xFFE6F1FF),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: teal, size: 17),
                    SizedBox(width: 7),
                    Text(
                      'Build healthy daily habits',
                      style: TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _dailyChecklist() {
    final completed = _completedTasks.length;
    final progress = completed / _dailyTasks.length;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Daily Care Checklist',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$completed/${_dailyTasks.length}',
                style: const TextStyle(
                  color: teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFEDF1F6),
              valueColor: const AlwaysStoppedAnimation<Color>(teal),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completed == _dailyTasks.length
                ? 'Great job! You completed today’s checklist.'
                : 'Complete these simple tasks to track today’s care.',
            style: const TextStyle(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          ..._dailyTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            final isDone = _completedTasks.contains(index);

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isDone) {
                      _completedTasks.remove(index);
                    } else {
                      _completedTasks.add(index);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFF0FAF6)
                        : const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFFBDE8D8)
                          : const Color(0xFFF0F3F7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        task['icon'] as IconData,
                        color: isDone ? teal : blue,
                        size: 22,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] as String,
                              style: TextStyle(
                                color: navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['subtitle'] as String,
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
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isDone ? teal : const Color(0xFFBBC7D5),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _topicCard(Map<String, dynamic> topic) {
    final color = topic['color'] as Color;
    final cardBackground = topic['background'] as Color;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: () => _openTopic(topic),
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(topic['icon'] as IconData, color: color, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title'] as String,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      topic['subtitle'] as String,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF5DDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFFC35C32),
                size: 25,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Know the Warning Signs',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Persistent itching or licking',
            'Red, swollen or painful skin',
            'Open sores, discharge or an unusual smell',
            'Sudden or patchy hair loss',
          ].map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: Color(0xFFC35C32),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFF76594D),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'If symptoms persist or worsen, arrange a veterinary '
            'assessment. Seek urgent care for severe pain, rapidly '
            'spreading swelling, breathing difficulty or collapse.',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vetTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.medical_services_rounded,
            color: Color(0xFF8EE3D2),
            size: 28,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your vet is your best partner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Skin problems can have many causes. These tips are '
                  'for general education and do not replace a veterinary '
                  'examination or diagnosis.',
                  style: TextStyle(
                    color: Color(0xFFD6E4F2),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          children: [
            _appBar(),
            const SizedBox(height: 22),
            _heroBanner(),
            const SizedBox(height: 27),
            _sectionTitle(
              'Your Daily Routine',
              'A few simple checks can help you spot changes early.',
            ),
            _dailyChecklist(),
            const SizedBox(height: 28),
            _sectionTitle(
              'Explore Care Guides',
              'Choose a topic to learn more about everyday prevention.',
            ),
            ..._topics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _topicCard(topic),
              ),
            ),
            const SizedBox(height: 14),
            _warningCard(),
            const SizedBox(height: 16),
            _vetTipCard(),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Made with 💚 for healthier, happier dogs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
