class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String timeText; // e.g., "08:00 AM"
  final String frequency; // e.g., "Daily", "Weekly"
  final int? interval; // e.g., 5
  final String? intervalUnit; // 'minutes','hours','days','daily'
  final int hour;
  final int minute;
  final int? year;
  final int? month;
  final int? day;
  final String? sound; // New field for sound name
  final int? totalPills;
  final String? endDate; // yyyy-MM-dd
  bool isTaken;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.timeText,
    required this.frequency,
    required this.hour,
    required this.minute,
    this.year,
    this.month,
    this.day,
    this.sound,
    this.totalPills,
    this.endDate,
    this.interval,
    this.intervalUnit,
    this.isTaken = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'timeText': timeText,
      'frequency': frequency,
      'interval': interval,
      'intervalUnit': intervalUnit,
      'totalPills': totalPills,
      'endDate': endDate,
      'hour': hour,
      'minute': minute,
      'year': year,
      'month': month,
      'day': day,
      'sound': sound,
      'isTaken': isTaken ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      timeText: map['timeText'],
      frequency: map['frequency'],
      interval: map['interval'],
      intervalUnit: map['intervalUnit'],
      hour: map['hour'],
      minute: map['minute'],
      year: map['year'],
      month: map['month'],
      day: map['day'],
      sound: map['sound'],
      isTaken: map['isTaken'] == 1,
      totalPills: map['totalPills'],
      endDate: map['endDate'],
    );
  }

  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    String? timeText,
    String? frequency,
    int? hour,
    int? minute,
    int? year,
    int? month,
    int? day,
    String? sound,
    int? totalPills,
    String? endDate,
    int? interval,
    String? intervalUnit,
    bool? isTaken,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timeText: timeText ?? this.timeText,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      totalPills: totalPills ?? this.totalPills,
      endDate: endDate ?? this.endDate,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      sound: sound ?? this.sound,
      isTaken: isTaken ?? this.isTaken,
    );
  }

  // Calculate doses for a specific day with continuity support
  List<DateTime> getOccurrencesForDay(DateTime date) {
    final start = DateTime(
      year ?? date.year,
      month ?? date.month,
      day ?? date.day,
      hour,
      minute,
    );
    final dateOnly = DateTime(date.year, date.month, date.day);
    final tomorrow = dateOnly.add(const Duration(days: 1));
    final startDateOnly = DateTime(start.year, start.month, start.day);

    if (dateOnly.isBefore(startDateOnly)) return [];

    // Daily logic
    if (frequency == 'Daily' || intervalUnit == 'daily') {
      return [DateTime(date.year, date.month, date.day, hour, minute)];
    }

    // Interval logic (days)
    if (intervalUnit == 'days' && interval != null) {
      final diff = dateOnly.difference(startDateOnly).inDays;
      if (diff >= 0 && diff % interval! == 0) {
        return [DateTime(date.year, date.month, date.day, hour, minute)];
      }
      return [];
    }

    // Interval logic (hours/minutes) - Precise anchor calculation
    if ((intervalUnit == 'hours' || intervalUnit == 'minutes') && interval != null) {
      final int intervalSeconds = (intervalUnit == 'hours') ? interval! * 3600 : interval! * 60;
      
      // Calculate how many seconds have passed since absolute start until start of 'date'
      final Duration timeFromStartToToday = dateOnly.difference(start);
      final int secondsFromStartToToday = timeFromStartToToday.inSeconds;

      // Find first occurrence on or after dateOnly
      int intervalsToFirstToday;
      if (secondsFromStartToToday <= 0) {
        intervalsToFirstToday = 0;
      } else {
        intervalsToFirstToday = (secondsFromStartToToday / intervalSeconds).ceil();
      }

      DateTime current = start.add(Duration(seconds: intervalsToFirstToday * intervalSeconds));
      List<DateTime> dayOccurrences = [];

      // Collect all occurrences that fall within this day
      while (current.isBefore(tomorrow)) {
        if (!current.isBefore(dateOnly)) {
          dayOccurrences.add(current);
        }
        current = current.add(Duration(seconds: intervalSeconds));
        if (dayOccurrences.length > 50) break; // Safety
      }
      return dayOccurrences;
    }

    return [];
  }

  String localeStockText(String langCode) {
    if (langCode == 'ar') {
      return 'الكمية الحالية: ${totalPills ?? 0} حبة';
    } else {
      return 'Current Stock: ${totalPills ?? 0} pills';
    }
  }
}

class DoseOccurrence {
  final Medication medication;
  final DateTime scheduledTime;
  final bool isTaken;

  DoseOccurrence({
    required this.medication,
    required this.scheduledTime,
    this.isTaken = false,
  });
}
