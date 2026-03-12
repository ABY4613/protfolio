import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

void main() => runApp(const DataBoardApp());

final ValueNotifier<bool> isDarkTheme = ValueNotifier(true);

class DataBoardApp extends StatelessWidget {
  const DataBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTheme,
      builder: (context, isDark, child) {
        final darkBg = const Color(0xFF070B14);
        final lightBg = const Color(0xFFF1F5F9);
        final primaryColor = isDark
            ? Colors.cyanAccent.shade400
            : Colors.indigo.shade600;
        final surfaceColor = isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05);

        return MaterialApp(
          title: 'Justin Joji Mathew | Data Analytics',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? darkBg : lightBg,
            primaryColor: primaryColor,
            colorScheme:
                (isDark ? const ColorScheme.dark() : const ColorScheme.light())
                    .copyWith(
                      primary: primaryColor,
                      secondary: Colors.deepPurpleAccent,
                      surface: surfaceColor,
                    ),
            textTheme: GoogleFonts.outfitTextTheme(
              isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
            ),
            useMaterial3: true,
          ),
          home: const CursorWrapper(child: GlassmorphismDashboard()),
        );
      },
    );
  }
}

// ----------------------------------------------------
// SLEEK FLUID CURSOR
// ----------------------------------------------------
class CursorWrapper extends StatefulWidget {
  final Widget child;
  const CursorWrapper({super.key, required this.child});

  @override
  State<CursorWrapper> createState() => _CursorWrapperState();
}

class _CursorWrapperState extends State<CursorWrapper>
    with SingleTickerProviderStateMixin {
  Offset _mousePos = const Offset(-200, -200);
  Offset _trailingPos = const Offset(-200, -200);
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_mousePos.dx != -200) {
        setState(() {
          _trailingPos = Offset.lerp(_trailingPos, _mousePos, 0.2) ?? _mousePos;
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    if (isMobile) return widget.child;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTheme,
      builder: (context, isDark, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.none,
          onHover: (e) => setState(() => _mousePos = e.position),
          onExit: (e) => setState(() => _mousePos = const Offset(-200, -200)),
          child: Stack(
            children: [
              widget.child,
              // Trailing Cursor
              AnimatedPositioned(
                duration: Duration.zero,
                left: _trailingPos.dx - 20,
                top: _trailingPos.dy - 20,
                child: IgnorePointer(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Main Dot
              AnimatedPositioned(
                duration: Duration.zero,
                left: _mousePos.dx - 4,
                top: _mousePos.dy - 4,
                child: IgnorePointer(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// DYNAMIC GLASSMORPHISM BACKGROUND & LAYOUT
// ----------------------------------------------------
class GlassmorphismDashboard extends StatelessWidget {
  const GlassmorphismDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: isMobile ? const Drawer(child: SidebarContent()) : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            )
          : null,
      body: Stack(
        children: [
          // Moving Blobs
          const BackgroundBlobs(),
          // Glass Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.5),
              ),
            ),
          ),

          Row(
            children: [
              if (!isMobile) const SidebarContainer(),
              const Expanded(child: ResponsiveContent()),
            ],
          ),

          // Natural Hanging Rope Bulb
          if (!isMobile)
            const Positioned(top: 0, right: 60, child: PhysicsPullSwitch()),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// PHYSICS-BASED ROPE SWITCH
// ----------------------------------------------------
class PhysicsPullSwitch extends StatefulWidget {
  const PhysicsPullSwitch({super.key});
  @override
  State<PhysicsPullSwitch> createState() => _PhysicsPullSwitchState();
}

class _PhysicsPullSwitchState extends State<PhysicsPullSwitch>
    with SingleTickerProviderStateMixin {
  double pullDistance = 0.0;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTheme,
      builder: (context, isDark, child) {
        double maxPull = 120;

        return GestureDetector(
          onVerticalDragStart: (_) => setState(() => isDragging = true),
          onVerticalDragUpdate: (details) {
            setState(() {
              pullDistance += details.delta.dy;
              if (pullDistance < 0) pullDistance = 0;
              if (pullDistance > maxPull) pullDistance = maxPull;
            });
          },
          onVerticalDragEnd: (details) {
            if (pullDistance > maxPull * 0.7) {
              isDarkTheme.value = !isDarkTheme.value;
            }
            setState(() {
              isDragging = false;
              pullDistance = 0;
            });
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: pullDistance, end: pullDistance),
            duration: isDragging
                ? Duration.zero
                : const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Actual drawn rope
                  Container(
                    width: 4,
                    height: 80 + (isDragging ? value * 0.8 : value * 0.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 80 + (isDragging ? value * 0.8 : value * 0.5) - 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.cyanAccent.withOpacity(0.5)
                                : Colors.orangeAccent.withOpacity(0.5),
                            blurRadius: isDark ? 20 : 30,
                            spreadRadius: isDark ? 5 : 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        isDark
                            ? Icons.wb_incandescent_outlined
                            : Icons.wb_incandescent,
                        size: 32,
                        color: isDark ? Colors.cyanAccent : Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// ABSTRACT BACKGROUND BLOBS
// ----------------------------------------------------
class BackgroundBlobs extends StatefulWidget {
  const BackgroundBlobs({super.key});
  @override
  State<BackgroundBlobs> createState() => _BackgroundBlobsState();
}

class _BackgroundBlobsState extends State<BackgroundBlobs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          children: [
            Positioned(
              left: -100 + val * 200,
              top: 100 + val * 100,
              child: _blob(Theme.of(context).primaryColor, 400),
            ),
            Positioned(
              right: -50 - val * 150,
              bottom: 200 - val * 100,
              child: _blob(Theme.of(context).colorScheme.secondary, 500),
            ),
            Positioned(
              left: 300 + val * 300,
              bottom: -100 + val * 200,
              child: _blob(Colors.deepPurple, 300),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(Color c, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withOpacity(0.3),
      ),
    );
  }
}

// ----------------------------------------------------
// SIDEBAR
// ----------------------------------------------------
class SidebarContainer extends StatelessWidget {
  const SidebarContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        child: SidebarContent(),
      ),
    );
  }
}

class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          // Lottie Avatar Integration replacing NetworkImage for a tech feel
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
              border: Border.all(color: theme.primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Lottie.network(
                'https://lottie.host/80404da6-27ab-4971-bfbd-b203cba26002/mH3nFv8hP8.json',
                fit: BoxFit.cover,
                errorBuilder: (context, obj, stack) => Icon(
                  Icons.data_exploration,
                  size: 60,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),
          Text(
            'JUSTIN JOJI',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          Text(
            'MATHEW',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 0.9,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
            ),
            child: Text(
              'DATA ANALYST',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _infoTile(Icons.location_on_rounded, 'Pathanamthitta, Kerala', theme),
          const SizedBox(height: 16),
          _infoTile(
            Icons.mail_rounded,
            'justinjoji251@gmail.com',
            theme,
            'mailto:justinjoji251@gmail.com',
          ),
          const SizedBox(height: 16),
          _infoTile(
            Icons.phone_rounded,
            '+91 8078824372',
            theme,
            'tel:+918078824372',
          ),
          const Spacer(),
          // Social Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialNode(
                FontAwesomeIcons.github,
                'https://github.com/Justin-Joji',
                theme,
              ),
              const SizedBox(width: 20),
              _socialNode(
                FontAwesomeIcons.linkedinIn,
                'https://linkedin.com/in/justin-joji-mathew',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text, ThemeData theme, [String? url]) {
    return InkWell(
      onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
      hoverColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialNode(dynamic icon, String url, ThemeData theme) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () => launchUrl(Uri.parse(url)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHovered
                    ? theme.primaryColor
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ]
                    : [],
              ),
              child: FaIcon(
                icon,
                size: 20,
                color: isHovered
                    ? (theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white)
                    : theme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// MAIN DASHBOARD CONTENT SCROLL
// ----------------------------------------------------
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 40,
        isMobile ? 80 : 40,
        isMobile ? 20 : 60,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANALYTICS HQ',
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Detail-oriented and analytical Data Analyst focused on transforming complex data into actionable, automated insights.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 60),
          _sectionTitle('Core Analytics Metrics'),
          const MetricsGlassGrid(),

          const SizedBox(height: 60),
          _sectionTitle('Tool Proficiency & Workflow'),
          if (isMobile) ...[
            const SkillsRadarChart(),
            const SizedBox(height: 20),
            const PulseActivityChart(),
          ] else
            Row(
              children: [
                const Expanded(child: SkillsRadarChart()),
                const SizedBox(width: 30),
                const Expanded(flex: 2, child: PulseActivityChart()),
              ],
            ),

          const SizedBox(height: 80),
          _sectionTitle('High-Impact Projects'),
          const ImageProjectsGrid(),

          const SizedBox(height: 80),
          _sectionTitle('Experience & Credentials'),
          if (isMobile) ...[
            const FancyTimelineFeed(),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 3, child: FancyTimelineFeed()),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'EDUCATION',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'B.Tech Computer Science\nMusaliar College of Engineering & Tech\n2021 – 2025',
                          style: TextStyle(height: 1.6),
                        ),
                        const Divider(height: 40, color: Colors.white24),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 40,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'CERTIFICATIONS',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'IBM Introduction to Data Analytics\nCoursera • Feb 2026',
                          style: TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 100),
        ],
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// BEAUTIFUL GLASS GRID METRICS
// ----------------------------------------------------
class MetricsGlassGrid extends StatelessWidget {
  const MetricsGlassGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {
        'title': 'TOTAL PORTFOLIOS',
        'val': '5+',
        'icon': Icons.folder_copy_rounded,
        'color': Colors.blueAccent,
      },
      {
        'title': 'DATA SETS MINED',
        'val': '20M+',
        'icon': Icons.storage_rounded,
        'color': Colors.cyanAccent,
      },
      {
        'title': 'DASHBOARDS',
        'val': '12',
        'icon': Icons.dashboard_rounded,
        'color': Colors.purpleAccent,
      },
      {
        'title': 'QUERIES WRITTEN',
        'val': '10k+',
        'icon': Icons.terminal_rounded,
        'color': Colors.greenAccent,
      },
    ];
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: metrics.map((m) {
        return Container(
          width: isMobile
              ? double.infinity
              : (MediaQuery.of(context).size.width - 320 - 80 - 60) / 4,
          constraints: const BoxConstraints(minWidth: 160),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (m['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  m['icon'] as IconData,
                  color: m['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                m['val'] as String,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                m['title'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ----------------------------------------------------
// ANIMATED SKILLS CHART
// ----------------------------------------------------
class SkillsRadarChart extends StatelessWidget {
  const SkillsRadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 10),
              const Text(
                'TOOL UTILIZATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child:
                PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: 30,
                            color: Colors.blueAccent,
                            title: 'Power BI',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: 20,
                            color: Colors.deepPurpleAccent,
                            title: 'Python',
                            radius: 45,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: 25,
                            color: Colors.cyanAccent,
                            title: 'SQL',
                            radius: 48,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: Colors.pinkAccent,
                            title: 'Tableau',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: 10,
                            color: Colors.greenAccent,
                            title: 'Excel',
                            radius: 35,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 4.seconds, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class PulseActivityChart extends StatelessWidget {
  const PulseActivityChart({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AUTOMATED WORKFLOWS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.redAccent),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.2, end: 1),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (v, m) => Text(
                        'Day ${v.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 4),
                      FlSpot(2, 3),
                      FlSpot(3, 8),
                      FlSpot(4, 6),
                      FlSpot(5, 9),
                      FlSpot(6, 7),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: theme.colorScheme.secondary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, d, i) => FlDotCirclePainter(
                        radius: 6,
                        color: theme.colorScheme.secondary,
                        strokeWidth: 2,
                        strokeColor: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary.withOpacity(0.4),
                          theme.colorScheme.secondary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// IMAGE PROJECTS GRID WITH HOVER 3D
// ----------------------------------------------------
class ImageProjectsGrid extends StatelessWidget {
  const ImageProjectsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {
        'name': 'Tata Motors Analysis',
        'type': 'POWER BI',
        'img':
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070',
        'desc': 'Vehicle sales analytics from 2000-2025.',
      },
      {
        'name': 'ABB Stock Time-Series',
        'type': 'TIME SERIES',
        'img':
            'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?q=80&w=2070',
        'desc': 'Advanced predictive modeling of stock behavior.',
      },
      {
        'name': 'Uber Rides',
        'type': 'TABLEAU',
        'img':
            'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=2070',
        'desc': 'Mapping global ride cancellations & stats.',
      },
      {
        'name': 'IBM HR Insights',
        'type': 'DATA WAREHOUSING',
        'img':
            'https://images.unsplash.com/photo-1553877522-43269d4ea984?q=80&w=2070',
        'desc': 'Employee attrition forecasting model.',
      },
      {
        'name': 'GIVEAT System API',
        'type': 'PYTHON FLASK',
        'img':
            'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?q=80&w=2070',
        'desc': 'End-to-end backend data handling.',
      },
    ];

    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: projects
          .map((p) => _InteractiveProjCard(p: p, isMobile: isMobile))
          .toList(),
    );
  }
}

class _InteractiveProjCard extends StatefulWidget {
  final Map<String, String> p;
  final bool isMobile;
  const _InteractiveProjCard({required this.p, required this.isMobile});

  @override
  State<_InteractiveProjCard> createState() => _InteractiveProjCardState();
}

class _InteractiveProjCardState extends State<_InteractiveProjCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.isMobile
            ? double.infinity
            : (MediaQuery.of(context).size.width - 320 - 80 - 48) / 3,
        height: 280,
        constraints: const BoxConstraints(minWidth: 260),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              AnimatedScale(
                scale: isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: Image.network(
                  widget.p['img']!,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(color: Colors.grey.shade900),
                ),
              ),
              // Gradient Overlay
              AnimatedOpacity(
                opacity: isHovered ? 0.9 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(1.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.p['type']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.p['name']!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isHovered ? 40 : 0,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Text(
                            widget.p['desc']!,
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// CREATIVE TIMELINE COMPONENT
// ----------------------------------------------------
class FancyTimelineFeed extends StatelessWidget {
  const FancyTimelineFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 28,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Text(
                'PROFESSIONAL HISTORY',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _feedItem(
            context,
            'Data Analyst Intern',
            'Techolas Technologies',
            'Jul 2025 – Feb 2026',
            Icons.work_outline_rounded,
            true,
          ),
        ],
      ),
    );
  }

  Widget _feedItem(
    BuildContext context,
    String t,
    String c,
    String d,
    IconData i,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.secondary),
                ),
                child: Icon(i, color: theme.colorScheme.secondary, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        c,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.circle, size: 4, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        d,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '• Performed deep data cleaning & feature engineering.\n• Developed interactive BI dashboards reducing report time by 40%.\n• Designed and optimized relational databases.',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
