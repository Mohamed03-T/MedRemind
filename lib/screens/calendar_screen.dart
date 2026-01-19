import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/medication.dart';
import 'day_detail_screen.dart';

enum CalendarViewMode { days, weeks, months }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  final CalendarViewMode _mode = CalendarViewMode.days;
  final GlobalKey todayKey = GlobalKey();
  int _centerRetries = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).loadForMonth(_focusedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerToday());
      // Extra delayed attempt in case layout finishes slightly later
      Future.delayed(const Duration(milliseconds: 300), () => _centerToday());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
      Provider.of<CalendarProvider>(context, listen: false).loadForMonth(_focusedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerToday());
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
      Provider.of<CalendarProvider>(context, listen: false).loadForMonth(_focusedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerToday());
    });
  }

  void _centerToday() {
    try {
      if (!_scrollController.hasClients) {
        debugPrint('[_centerToday] attempt=$_centerRetries, no clients yet');
        if (_centerRetries < 12) {
          _centerRetries++;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 180), () => _centerToday());
          });
        }
        return;
      }

      // Calculate grid index for today (independent of render tree)
      final now = DateTime.now();
      final first = DateTime(_focusedDate.year, _focusedDate.month, 1);
      final startWeekday = first.weekday % 7;
      final todayIndex = startWeekday + (now.day - 1);
      final row = todayIndex ~/ 3; // 3 columns
      
      // Item dimensions based on GridView.count(childAspectRatio: 0.82, crossAxisCount: 3)
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = (screenWidth - 16 - 16) / 3; // width - horizontal padding / 3 columns
      final itemHeight = itemWidth / 0.82; // childAspectRatio = 0.82
      const itemMargin = 8.0;
      const verticalPadding = 8.0;
      final totalItemHeight = itemHeight + 2 * itemMargin;
      
      // Calculate scroll offset to center the row vertically
      final rowStartY = verticalPadding + row * totalItemHeight;
      final rowCenterY = rowStartY + totalItemHeight / 2;
      final viewportHeight = MediaQuery.of(context).size.height - kToolbarHeight;
      final targetOffset = (rowCenterY - viewportHeight / 2).clamp(0.0, _scrollController.position.maxScrollExtent);
      
      debugPrint('[_centerToday] todayIndex=$todayIndex, row=$row, itemHeight=$itemHeight, targetOffset=$targetOffset, maxExtent=${_scrollController.position.maxScrollExtent}');

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );

      _centerRetries = 0;
    } catch (e) {
      debugPrint('[_centerToday] error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meds = Provider.of<MedicationProvider>(context).medications;
    final cal = Provider.of<CalendarProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final first = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);

    final startWeekday = first.weekday % 7; // make Sunday=0

    List<Widget> dayWidgets = [];
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    final nowTime = DateTime.now();

    for (int d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(_focusedDate.year, _focusedDate.month, d);
      final isToday = DateUtils.isSameDay(dt, DateTime.now());
      final isPast = dt.isBefore(DateTime(nowTime.year, nowTime.month, nowTime.day));
      final isDark = theme.brightness == Brightness.dark;
      
      // Calculate completion percentage based on specific occurrences
      List<DateTime> dayOccurrences = [];
      for (var m in meds) {
        dayOccurrences.addAll(m.getOccurrencesForDay(dt));
      }
      
      final int totalTasks = dayOccurrences.length;
      final int completedTasks = cal.totalCompletionsFor(dt); 
      final double percentage = totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;

      // Stats for this specific day
      int dayTaken = completedTasks;
      int dayScheduledUntilNow = 0;
      if (isPast) {
        dayScheduledUntilNow = totalTasks;
      } else if (isToday) {
        for (var occ in dayOccurrences) {
          if (occ.isBefore(nowTime)) dayScheduledUntilNow++;
        }
      }
      int dayMissed = (dayScheduledUntilNow - dayTaken).clamp(0, 99);

      // Color/Gradient logic
      List<Color> gradientColors = theme.brightness == Brightness.light 
          ? [Colors.white, const Color(0xFFF1F5F9)] 
          : [const Color(0xFF1E293B), const Color(0xFF0F172A)];
      Color borderColor = theme.brightness == Brightness.light 
          ? const Color(0xFFE2E8F0) 
          : const Color(0xFF334155);
      Color textColor = theme.colorScheme.onSurface;
      Color subTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

      if (totalTasks > 0) {
        if (percentage == 1.0) {
          gradientColors = [const Color(0xFF10B981), const Color(0xFF059669)];
          borderColor = Colors.transparent;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.9);
        } else if (percentage >= 0.5) {
          gradientColors = [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
          borderColor = Colors.transparent;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.9);
        } else if (percentage > 0) {
          gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
          borderColor = Colors.transparent;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.9);
        }
      }

      if (isToday) {
        borderColor = totalTasks > 0 ? Colors.white : theme.colorScheme.primary;
      }

      dayWidgets.add(GestureDetector(
        onTap: () {
          cal.loadForDate(dt);
          final List<DoseOccurrence> occurrences = [];
          for (var m in meds) {
            final times = m.getOccurrencesForDay(dt);
            for (var time in times) {
              occurrences.add(DoseOccurrence(medication: m, scheduledTime: time));
            }
          }

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                opacity: animation,
                child: DayDetailScreen(
                  date: dt,
                  occurrences: occurrences,
                ),
              ),
            ),
          );
        },
        child: Hero(
          tag: 'day_$dt',
           child: Container(
            key: isToday ? todayKey : null,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
                width: isToday ? 2.5 : 1.0,
              ),
              boxShadow: [
                if (totalTasks > 0 && percentage > 0)
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: isDark ? 0.3 : 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle shine/decoration
                if (totalTasks > 0 && percentage > 0)
                  Positioned(
                    right: -15,
                    top: -15,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // Main Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.today,
                                style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (totalTasks > 0)
                            Text(
                              '${(percentage * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: subTextColor,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        d.toString(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      if (totalTasks > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMiniIndicator(Icons.arrow_upward, dayTaken, const Color(0xFF10B981), percentage > 0),
                            const SizedBox(width: 8),
                            _buildMiniIndicator(Icons.arrow_downward, dayMissed, const Color(0xFFEF4444), percentage > 0),
                          ],
                        )
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
    }


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          DateFormat.yMMMM(locale).format(_focusedDate),
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(locale == 'ar' ? Icons.chevron_right : Icons.chevron_left, color: theme.colorScheme.primary),
          onPressed: _prevMonth,
        ),
        actions: [
          IconButton(
            icon: Icon(locale == 'ar' ? Icons.chevron_left : Icons.chevron_right, color: theme.colorScheme.primary),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_mode == CalendarViewMode.days)
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                controller: _scrollController,
                crossAxisCount: 3,
                childAspectRatio: 0.82,
                children: dayWidgets,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'عرض ${_mode.name} قيد التطوير',
                      style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.5), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniIndicator(IconData icon, int count, Color defaultColor, bool isColored) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isColored ? Colors.white : defaultColor,
        ),
        const SizedBox(width: 3),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isColored ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

