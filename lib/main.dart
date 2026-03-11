import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aby Babu | Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFFFF0031), // Nothing Red
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF0031),
          secondary: Color(0xFFFF0031),
          surface: Color(0xFF111111),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              displayLarge: GoogleFonts.silkscreen(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
              displayMedium: GoogleFonts.silkscreen(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              bodyLarge: GoogleFonts.inter(fontSize: 18, color: Colors.white70),
            ),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class HoverInvert extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered, Color color)
  builder;
  final Color baseColor;
  final Color invertColor;

  const HoverInvert({
    super.key,
    required this.builder,
    this.baseColor = Colors.white,
    this.invertColor = const Color(0xFFFF0031),
  });

  @override
  State<HoverInvert> createState() => _HoverInvertState();
}

class _HoverInvertState extends State<HoverInvert> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color currentColor = _isHovered
        ? (widget.baseColor == const Color(0xFFFF0031)
              ? Colors.white
              : widget.invertColor)
        : widget.baseColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: widget.builder(context, _isHovered, currentColor),
    );
  }
}

class ChargerCursor extends StatelessWidget {
  final Offset position;
  const ChargerCursor({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0031).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF0031), width: 1.5),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cable_rounded, size: 20, color: Color(0xFFFF0031)),
                Icon(Icons.bolt_rounded, size: 10, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  int _currentIndex = 0;
  final ValueNotifier<Offset> _mousePosition = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mousePosition.dispose();
    super.dispose();
  }

  void _updateMousePos(PointerEvent event) {
    _mousePosition.value = event.position;
  }

  void _handleScroll() {
    // Basic logic to update active nav item based on scroll position
    // For simplicity, we'll just track if we're at the top, middle, or bottom
    // A more precise implementation would use RenderBox position
    final offset = _scrollController.offset;
    int newIndex = 0;
    if (offset > 2400) {
      newIndex = 4; // Contact
    } else if (offset > 1600) {
      newIndex = 3; // Projects
    } else if (offset > 1000) {
      newIndex = 2; // Skills
    } else if (offset > 400) {
      newIndex = 1; // Experience
    } else {
      newIndex = 0; // Home
    }

    if (newIndex != _currentIndex && mounted) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          return MouseRegion(
            onHover: _updateMousePos,
            cursor: isMobile
                ? SystemMouseCursors.basic
                : SystemMouseCursors.none,
            child: Stack(
              children: [
                // Background Grid Effect
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(painter: GridPainter()),
                  ),
                ),

                // Main Content
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SizedBox(height: 60, key: _homeKey),
                      ProfileHeader(isMobile: isMobile),
                      const SizedBox(height: 40),
                      IntroSection(isMobile: isMobile),
                      const SizedBox(height: 80),
                      ExperienceSection(
                        isMobile: isMobile,
                        key: _experienceKey,
                      ),
                      const SizedBox(height: 80),
                      SkillsSection(isMobile: isMobile, key: _skillsKey),
                      const SizedBox(height: 80),
                      const QuoteSection(),
                      const SizedBox(height: 80),
                      PremiumProjectsSection(
                        isMobile: isMobile,
                        key: _projectsKey,
                      ),
                      const SizedBox(height: 80),
                      ContributionSection(isMobile: isMobile),
                      const SizedBox(height: 80),
                      ContactSection(isMobile: isMobile, key: _contactKey),
                      const SizedBox(height: 100),
                      FooterSection(isMobile: isMobile),
                    ],
                  ),
                ),

                // Custom Charger Cursor
                if (!isMobile)
                  ValueListenableBuilder<Offset>(
                    valueListenable: _mousePosition,
                    builder: (context, pos, _) => ChargerCursor(position: pos),
                  ),

                // Floating Bottom Navigation
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC050505),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _navItem(Icons.home_outlined, 0, _homeKey),
                          _navItem(
                            Icons.work_outline_rounded,
                            1,
                            _experienceKey,
                          ),
                          _navItem(Icons.terminal_rounded, 2, _skillsKey),
                          _navItem(Icons.folder_outlined, 3, _projectsKey),
                          _navItem(
                            Icons.alternate_email_rounded,
                            4,
                            _contactKey,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 20,
                            width: 1,
                            color: Colors.white10,
                          ),
                          _navSocialItem(
                            FontAwesomeIcons.github,
                            'https://github.com/ABY4613',
                          ),
                          _navSocialItem(
                            FontAwesomeIcons.linkedinIn,
                            'https://linkedin.com/in/aby-babu',
                          ),
                          _navSocialItem(
                            FontAwesomeIcons.xTwitter,
                            'https://x.com/aby_dot',
                          ),
                          _navSocialItem(
                            FontAwesomeIcons.instagram,
                            'https://instagram.com/i.abyiii',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 1, end: 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _navSocialItem(dynamic icon, String url) {
    return HoverInvert(
      builder: (context, isHovered, color) {
        return IconButton(
          onPressed: () => launchUrl(Uri.parse(url)),
          icon: _buildIcon(
            icon,
            size: 18,
            color: isHovered ? const Color(0xFFFF0031) : Colors.white38,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(),
        );
      },
    );
  }

  Widget _navItem(IconData icon, int index, GlobalKey key) {
    bool isActive = _currentIndex == index;
    return HoverInvert(
      builder: (context, isHovered, color) {
        return InkWell(
          onTap: () => _scrollToKey(key),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 20 : 12,
              vertical: 10,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive || isHovered
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? (isHovered ? Colors.white : const Color(0xFFFF0031))
                      : (isHovered ? const Color(0xFFFF0031) : Colors.white38),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isHovered ? Colors.white : const Color(0xFFFF0031),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final bool isMobile;
  const ProfileHeader({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              'https://api.dicebear.com/7.x/avataaars/png?seed=Aby', // Placeholder for your photo
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABY BABU',
                  style: GoogleFonts.silkscreen(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@aby_dot',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            _headerSocial(
              FontAwesomeIcons.github,
              'https://github.com/ABY4613',
            ),
            const SizedBox(width: 10),
            _headerSocial(
              FontAwesomeIcons.linkedinIn,
              'https://linkedin.com/in/aby-babu',
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Get in Touch',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerSocial(dynamic icon, String url) {
    return IconButton(
      onPressed: () => launchUrl(Uri.parse(url)),
      icon: _buildIcon(icon, size: 18, color: Colors.white70),
    );
  }
}

class IntroSection extends StatelessWidget {
  final bool isMobile;
  const IntroSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: isMobile ? 18 : 22,
                height: 1.5,
                color: Colors.white70,
              ),
              children: [
                const TextSpan(text: 'Surprise me, a '),
                TextSpan(
                  text: 'Mobile Developer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white24,
                  ),
                ),
                const TextSpan(
                  text:
                      '. Fancy title, huh? But here\'s the kicker — I\'m not your average ',
                ),
                TextSpan(
                  text: 'code monkey',
                  style: TextStyle(
                    fontFamily: GoogleFonts.silkscreen().fontFamily,
                    color: Colors.white,
                  ),
                ),
                const TextSpan(text: '. I thrive at the intersection of '),
                TextSpan(
                  text: 'elegant design',
                  style: TextStyle(color: const Color(0xFFFF0031)),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'robust, efficient code',
                  style: TextStyle(color: const Color(0xFFFF0031)),
                ),
                const TextSpan(
                  text:
                      '. I\'m passionate about crafting seamless user experiences.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0031),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Available for projects',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF0031),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const gap = 40.0;
    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Removed old HeroSection in favor of new ProfileHeader and IntroSection

// Combined AboutSection logic into IntroSection for that design match

class SkillsSection extends StatelessWidget {
  final bool isMobile;
  const SkillsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> skills = [
      {'name': 'iOS Development', 'icon': Icons.apple},
      {'name': 'Android Development', 'icon': Icons.android},
      {'name': 'Flutter', 'icon': Icons.flutter_dash},
      {'name': 'React', 'icon': FontAwesomeIcons.react},
      {'name': 'TypeScript', 'icon': FontAwesomeIcons.terminal},
      {'name': 'JavaScript', 'icon': FontAwesomeIcons.js},
      {'name': 'Firebase', 'icon': Icons.local_fire_department},
      {'name': 'REST APIs', 'icon': Icons.api},
      {'name': 'Python', 'icon': FontAwesomeIcons.python},
      {'name': 'Git', 'icon': FontAwesomeIcons.gitAlt},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'THE KITCHEN'),
          const SizedBox(height: 10),
          Text(
            'My tech stack and tools',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skills
                .map((s) => _skillChip(s['name'], s['icon']))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _skillChip(String name, dynamic icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            name,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  final bool isMobile;
  const ExperienceSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final experiences = [
      {
        'title': 'iOS Developer',
        'type': 'Work',
        'company': 'Tech Solutions',
        'period': '2024 - Present',
        'location': 'On-site',
        'subtitle': 'Full-time',
      },
      {
        'title': 'MOBILE APP DEVELOPER',
        'type': 'Work',
        'company': 'Freelance',
        'period': '2023 - 2024',
        'location': 'Remote',
        'subtitle': 'Freelance',
      },
      {
        'title': 'MOBILE DEVELOPMENT INTERN',
        'type': 'Work',
        'company': 'Startup Inc',
        'period': '2023',
        'location': 'Kerala, India',
        'subtitle': 'Tech Intern',
      },
      {
        'title': 'MOBILE DEVELOPMENT',
        'type': 'Education',
        'company': 'Self Taught',
        'period': '2022',
        'location': '',
        'subtitle': '',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'THE JOURNEY'),
          const SizedBox(height: 40),
          ...experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF0031),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index != experiences.length - 1)
                          Expanded(
                            child: Container(width: 1, color: Colors.white12),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                exp['title']!,
                                style: GoogleFonts.silkscreen(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exp['type']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white24,
                              ),
                            ],
                          ),
                          if (exp['subtitle']!.isNotEmpty)
                            Text(
                              exp['subtitle']!,
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _expInfo(Icons.calendar_today, exp['period']!),
                              const SizedBox(width: 20),
                              if (exp['location']!.isNotEmpty)
                                _expInfo(
                                  Icons.location_on_outlined,
                                  exp['location']!,
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _expInfo(dynamic icon, String text) {
    return Row(
      children: [
        _buildIcon(icon, size: 14, color: Colors.white24),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
        ),
      ],
    );
  }
}

class ProjectsSection extends StatelessWidget {
  final bool isMobile;
  const ProjectsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {
        'num': '01',
        'name': 'Frusette Salad Delivery',
        'tech': 'Flutter, Firebase, Maps',
        'image': 'assets/images/p1.png',
        'desc':
            'Complete salad meal subscription and delivery ecosystem including mobile apps and web dashboards.',
        'links': ['https://admin.frusette.com/'],
      },
      {
        'num': '02',
        'name': 'Shyns Mart',
        'tech': 'Flutter, BLoC, Python',
        'image': 'assets/images/p2.png',
        'desc':
            'On-demand grocery and food purchase app with customer and delivery boy modules.',
        'links': [
          'https://play.google.com/store/apps/details?id=com.toqse.maliyekkalstore',
        ],
      },
      {
        'num': '03',
        'name': '24LAW App',
        'tech': 'Flutter, Dart, Firebase',
        'image': 'assets/images/p3.png',
        'desc':
            'Legal information app providing real-time court judgments and legal news.',
        'links': [
          'https://play.google.com/store/apps/details?id=com.the24law.app',
        ],
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'FEATURED PROJECTS'),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 30,
              mainAxisSpacing: 40,
              childAspectRatio: isMobile ? 0.85 : 0.75,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final proj = projects[index];
              return _ProjectCard(proj: proj, index: index);
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> proj;
  final int index;

  const _ProjectCard({required this.proj, required this.index});

  @override
  Widget build(BuildContext context) {
    return HoverInvert(
          baseColor: const Color(0xFF0A0A0A),
          invertColor: const Color(0xFF111111),
          builder: (context, isHovered, color) {
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isHovered
                      ? const Color(0xFFFF0031).withOpacity(0.5)
                      : Colors.white12,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Container
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            proj['image'] as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  color.withOpacity(0.8),
                                  color,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 20,
                          child: Text(
                            proj['num'] as String,
                            style: GoogleFonts.silkscreen(
                              color: Colors.white10,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proj['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isHovered
                                ? const Color(0xFFFF0031)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0031).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            proj['tech'] as String,
                            style: GoogleFonts.silkscreen(
                              color: const Color(0xFFFF0031),
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          proj['desc'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 13,
                            height: 1.6,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            for (var link in proj['links'] as List)
                              InkWell(
                                onTap: () => launchUrl(Uri.parse(link)),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            if (isHovered)
                              const Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                color: Color(0xFFFF0031),
                                size: 16,
                              ).animate().fadeIn().slideX(begin: -0.5, end: 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: (index * 150).ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class EducationSection extends StatelessWidget {
  final bool isMobile;
  const EducationSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'EDUCATION'),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bachelor of Computer Applications (BCA)',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '2021 – 2024',
                  style: GoogleFonts.silkscreen(
                    color: const Color(0xFFFF0031),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Musaliar College of Arts and Science, Pathanamthitta, Kerala',
                  style: TextStyle(color: Colors.white70),
                ),
                const Text(
                  'Affiliated to Mahatma Gandhi University, Kottayam',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ).animate().fadeIn(),
        ],
      ),
    );
  }
}

class QuoteSection extends StatelessWidget {
  const QuoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            '"Code is like humor. When you have to explain it, it\'s bad."',
            textAlign: TextAlign.center,
            style: GoogleFonts.silkscreen(
              fontSize: 24,
              color: Colors.white,
              height: 1.5,
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 20),
          Text('— Cory House', style: GoogleFonts.inter(color: Colors.white38)),
        ],
      ),
    );
  }
}

class ContributionSection extends StatelessWidget {
  final bool isMobile;
  const ContributionSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'CONTRIBUTION GRAPH'),
          const SizedBox(height: 15),
          Text(
            'A developer\'s journey isn\'t about perfect streaks—it\'s about showing up when it matters.',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: List.generate(35, (i) => _dotColumn())),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      'Less',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 5),
                    _dot(Colors.white12),
                    _dot(const Color(0x33FF0031)),
                    _dot(const Color(0x77FF0031)),
                    _dot(const Color(0xFFFF0031)),
                    const SizedBox(width: 5),
                    Text(
                      'More',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotColumn() {
    return Column(
      children: List.generate(7, (i) {
        final rand = (i + DateTime.now().millisecond) % 4;
        final color = rand == 0
            ? Colors.white10
            : rand == 1
            ? const Color(0x44FF0031)
            : rand == 2
            ? const Color(0x99FF0031)
            : const Color(0xFFFF0031);
        return _dot(color);
      }),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class ContactSection extends StatefulWidget {
  final bool isMobile;
  const ContactSection({super.key, required this.isMobile});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _sendWhatsAppMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and message')),
      );
      return;
    }

    final fullMessage =
        "Hello, my name is $name ($email).\n\nSubject: $subject\n\n$message";
    final encodedMessage = Uri.encodeComponent(fullMessage);
    final url = 'https://wa.me/916282554258?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 100),
      child: Column(
        children: [
          Text(
            'LET\'S WORK TOGETHER',
            style: GoogleFonts.silkscreen(fontSize: 28),
          ),
          const SizedBox(height: 15),
          Text(
            'Got a project in mind? Drop me a message and let\'s create something amazing together.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white38),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _contactInfo(Icons.email_outlined, 'abyb4613@gmail.com'),
              if (!widget.isMobile) const SizedBox(width: 40),
              if (!widget.isMobile)
                _contactInfo(Icons.phone_outlined, '+91 6282554258'),
            ],
          ),
          const SizedBox(height: 40),
          _buildForm(widget.isMobile),
        ],
      ),
    );
  }

  Widget _contactInfo(dynamic icon, String text) {
    return InkWell(
      onTap: () {
        final uri = text.contains('@')
            ? Uri.parse('mailto:$text')
            : Uri.parse('tel:${text.replaceAll(' ', '')}');
        launchUrl(uri);
      },
      child: Row(
        children: [
          _buildIcon(icon, size: 20, color: const Color(0xFFFF0031)),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return Column(
      children: [
        if (!isMobile)
          Row(
            children: [
              Expanded(child: _field('NAME', 'Your name', _nameController)),
              const SizedBox(width: 20),
              Expanded(
                child: _field('EMAIL', 'your@email.com', _emailController),
              ),
            ],
          )
        else ...[
          _field('NAME', 'Your name', _nameController),
          const SizedBox(height: 20),
          _field('EMAIL', 'your@email.com', _emailController),
        ],
        const SizedBox(height: 20),
        _field('SUBJECT', 'What\'s this about?', _subjectController),
        const SizedBox(height: 20),
        _field(
          'MESSAGE',
          'Tell me about your project...',
          _messageController,
          maxLines: 5,
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: _sendWhatsAppMessage,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SEND MESSAGE',
                    style: GoogleFonts.silkscreen(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.send, color: Colors.black, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.silkscreen(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12, fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
          ),
        ),
      ],
    );
  }
}

class FooterSection extends StatelessWidget {
  final bool isMobile;
  const FooterSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            'Designed and made with ❤️ and ☕',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () =>
                launchUrl(Uri.parse('https://buymeacoffee.com/abybabu')),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.coffee, color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Buy me a coffee',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerIcon(
                FontAwesomeIcons.github,
                'https://github.com/ABY4613',
              ),
              _footerIcon(
                FontAwesomeIcons.linkedinIn,
                'https://linkedin.com/in/aby-babu',
              ),
              _footerIcon(FontAwesomeIcons.xTwitter, 'https://x.com/aby_dot'),
              _footerIcon(
                FontAwesomeIcons.instagram,
                'https://instagram.com/aby_dot',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerIcon(dynamic icon, String url) {
    return IconButton(
      onPressed: () => launchUrl(Uri.parse(url)),
      icon: _buildIcon(icon, size: 18, color: Colors.white24),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return HoverInvert(
      builder: (context, isHovered, color) {
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isHovered ? Colors.white : const Color(0xFFFF0031),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.silkscreen(
                fontSize: 20,
                letterSpacing: 2,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 1,
                color: isHovered
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white12,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1, end: 0);
      },
    );
  }
}

Widget _buildIcon(dynamic icon, {double? size, Color? color}) {
  if (icon == null) return const SizedBox.shrink();

  // Checking runtimeType string is a reliable workaround for Flutter Web
  // type-checking issues with FaIconData.
  if (icon.runtimeType.toString().contains('FaIconData')) {
    return FaIcon(icon as dynamic, size: size, color: color);
  }
  return Icon(icon as IconData?, size: size, color: color);
}

class PremiumProjectsSection extends StatelessWidget {
  final bool isMobile;
  const PremiumProjectsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {
        'num': '01',
        'name': 'Frusette Salad',
        'subtitle': 'SUBSCRIPTION ECOSYSTEM',
        'tech': ['FLUTTER', 'FIREBASE', 'MAPS API'],
        'image': 'assets/images/p1.png',
        'desc':
            'A comprehensive farm-to-table delivery system with real-time tracking and automated subscriptions.',
        'link': 'https://admin.frusette.com/',
      },
      {
        'num': '02',
        'name': 'Shyns Mart',
        'subtitle': 'GROCERY & LOGISTICS',
        'tech': ['FLUTTER BLoC', 'REST API', 'PYTHON'],
        'image': 'assets/images/p2.png',
        'desc':
            'Dual-module application for vendors and delivery personnel with intelligent routing.',
        'link':
            'https://play.google.com/store/apps/details?id=com.toqse.maliyekkalstore',
      },
      {
        'num': '03',
        'name': '24LAW',
        'subtitle': 'LEGAL INTELLIGENCE',
        'tech': ['FLUTTER', 'FIREBASE', 'NLP'],
        'image': 'assets/images/p3.png',
        'desc':
            'AI-powered legal research tool delivering state-wise court judgments in real-time.',
        'link':
            'https://play.google.com/store/apps/details?id=com.the24law.app',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'FEATURED PROJECTS'),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: isMobile ? 0.85 : 0.75,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final proj = projects[index];
              return _PremiumProjectCard(proj: proj, index: index);
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumProjectCard extends StatelessWidget {
  final Map<String, dynamic> proj;
  final int index;

  const _PremiumProjectCard({required this.proj, required this.index});

  @override
  Widget build(BuildContext context) {
    return HoverInvert(
      baseColor: const Color(0xFF0F0F0F),
      invertColor: const Color(0xFF151515),
      builder: (context, isHovered, color) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFFFF0031).withOpacity(0.6)
                  : Colors.white12,
              width: 1.5,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: const Color(0xFFFF0031).withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background Number
              Positioned(
                bottom: -20,
                right: -10,
                child: Opacity(
                  opacity: 0.03,
                  child: Text(
                    proj['num'] as String,
                    style: GoogleFonts.silkscreen(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Area
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            proj['image'] as String,
                            fit: BoxFit.cover,
                            opacity: AlwaysStoppedAnimation(
                              isHovered ? 0.9 : 0.7,
                            ),
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF1A1A1A),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.white10,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'LOADING GRAPHICS...',
                                        style: GoogleFonts.silkscreen(
                                          fontSize: 8,
                                          color: Colors.white10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  color.withOpacity(0.2),
                                  color,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info Area
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proj['name'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    proj['subtitle'] as String,
                                    style: GoogleFonts.silkscreen(
                                      fontSize: 8,
                                      color: const Color(0xFFFF0031),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  launchUrl(Uri.parse(proj['link'] as String)),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isHovered
                                      ? const Color(0xFFFF0031)
                                      : Colors.white.withOpacity(0.05),
                                ),
                                child: Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 16,
                                  color: isHovered
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          proj['desc'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (proj['tech'] as List<String>)
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Text(
                                    t,
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Animated Scanline
              if (isHovered)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child:
                      Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0031).withOpacity(0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF0031),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .moveY(
                            begin: 0,
                            end: 450,
                            duration: const Duration(seconds: 2),
                            curve: Curves.linear,
                          ),
                ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: (index * 200).ms).slideX(begin: 0.1, end: 0);
  }
}
