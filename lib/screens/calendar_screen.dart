import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).loadForMonth(_focusedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerToday());
    });
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
      final ctx = todayKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          alignment: 0.5,
          curve: Curves.easeInOut,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meds = Provider.of<MedicationProvider>(context).medications;
    final cal = Provider.of<CalendarProvider>(context);

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
          ? [Colors.white, Colors.white] 
          : [theme.colorScheme.surface, theme.colorScheme.surface];
      Color borderColor = theme.brightness == Brightness.light 
          ? Colors.grey.shade200 
          : Colors.white.withValues(alpha: 0.1);
      Color textColor = theme.colorScheme.onSurface;
      Color subTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

      if (totalTasks > 0) {
        if (percentage == 1.0) {
          gradientColors = [Colors.green.shade500, Colors.green.shade700];
          borderColor = Colors.green.shade700;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.82);
        } else if (percentage >= 0.5) {
          gradientColors = [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)];
          borderColor = theme.colorScheme.primary;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.82);
        } else if (percentage > 0) {
          gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
          borderColor = Colors.orange.shade700;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.82);
        } else {
          // No tasks done yet
          borderColor = theme.brightness == Brightness.light ? Colors.grey.shade300 : Colors.white.withValues(alpha: 0.2);
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
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor,
                width: isToday ? 3.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0] == Colors.white ||
                          gradientColors[0] == theme.colorScheme.surface
                      ? theme.shadowColor.withValues(alpha: 0.1)
                      : gradientColors[1].withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
                    children: [
                      // Background Circle for Day Number (Subtle)
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Main Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header: Today Badge and Percentage
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'اليوم',
                                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (totalTasks > 0)
                                  Text(
                                    '${(percentage * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: subTextColor,
                                    ),
                                  ),
                              ],
                            ),
                      // Day Number
                      Text(
                        d.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      // Footer: Stats
                      if (totalTasks > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              _buildMiniIndicator(Icons.arrow_upward, dayTaken, Colors.green, subTextColor),
                              const SizedBox(width: 8),
                              _buildMiniIndicator(Icons.arrow_downward, dayMissed, Colors.red, subTextColor),
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
          DateFormat.yMMMM('ar').format(_focusedDate),
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          onPressed: _prevMonth,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          if (_mode == CalendarViewMode.days)
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                crossAxisCount: 3,
                childAspectRatio: 0.85,
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

  Widget _buildMiniIndicator(IconData icon, int count, Color defaultColor, Color adaptiveColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          // Use the specific color (Green/Red) if text isn't white (colored background)
          color: adaptiveColor.computeLuminance() > 0.8 ? adaptiveColor : defaultColor,
        ),
        const SizedBox(width: 2),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: adaptiveColor,
          ),
        ),
      ],
    );
  }
}
