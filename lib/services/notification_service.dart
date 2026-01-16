import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/medication.dart';
import 'database_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background actions here if needed
  debugPrint('Notification background action: ${notificationResponse.actionId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _db = DatabaseService();
  VoidCallback? onDataChanged;
  static const MethodChannel _batteryChannel = MethodChannel('com.mohamed.medremind/battery');

  Future<void> init() async {
    try {
      // Initialize Timezones
      tz.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = info.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone initialized successfully: $timeZoneName');
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Algiers'));
        debugPrint('Detected Algeria manually: Africa/Algiers');
      } catch (e2) {
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint('Fallback to UTC: $e');
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    ).then((_) => debugPrint('Notification initialization complete'))
     .catchError((e) => debugPrint('Notification initialization ERROR: $e'));

    // Create notification channels for different sounds
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    debugPrint('Android Plugin: ${androidPlugin != null}');

    final List<Map<String, String>> channels = [
      {'id': 'med_reminder_default_v2', 'name': 'الافتراضي', 'sound': 'default'},
      {'id': 'med_reminder_soft_bell_v2', 'name': 'تنبيه هادئ', 'sound': 'soft_bell'},
      {'id': 'med_reminder_loud_alarm_v2', 'name': 'تنبيه قوي', 'sound': 'loud_alarm'},
    ];

    for (var chan in channels) {
      await androidPlugin?.createNotificationChannel(AndroidNotificationChannel(
        chan['id']!,
        'تذكير الدواء (${chan['name']})',
        description: 'إشعارات تذكير الدواء بنغمة ${chan['name']}',
        importance: Importance.max,
        playSound: true,
        sound: chan['sound'] == 'default' 
            ? null 
            : RawResourceAndroidNotificationSound(chan['sound']),
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ));
      debugPrint('Channel ${chan['id']} creation requested');
    }

    // Request permissions
    final notifPerm = await androidPlugin?.requestNotificationsPermission();
    debugPrint('Notification Permission: $notifPerm');
    final alarmPerm = await androidPlugin?.requestExactAlarmsPermission();
    debugPrint('Exact Alarm Permission: $alarmPerm');

    if (Platform.isAndroid) {
      await requestBatteryOptimizations();
    }
  }

  Future<void> requestBatteryOptimizations() async {
    try {
      await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } on PlatformException catch (e) {
      debugPrint("Failed to request battery optimizations: '${e.message}'.");
    }
  }

  void _handleNotificationResponse(NotificationResponse details) async {
    final String? payload = details.payload;
    if (payload == null) return;

    // Payload expected format: "medicationId:instanceTimestamp"
    final parts = payload.split(':');
    if (parts.length < 2) return;
    
    final int medId = int.parse(parts[0]);
    final String timestamp = parts[1]; // yyyy-MM-dd
    
    if (details.actionId == 'action_taken') {
      await _db.insertCompletion(timestamp, medId);
      final remaining = await _db.decrementPills(medId);
      
      if (remaining != null && remaining > 0 && remaining <= 5) {
        // Show low stock warning
        await showLowStockNotification(medId, remaining);
      }
      
      debugPrint('Medication $medId marked as TAKEN for $timestamp. Remaining: $remaining');
      onDataChanged?.call();
    } else if (details.actionId == 'action_snooze') {
      // Reschedule in 10 minutes
      final now = tz.TZDateTime.now(tz.local);
      final snoozeTime = now.add(const Duration(minutes: 10));
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        medId + 999999, // Unique ID for snooze
        '⏰ غفوة: موعد دواء',
        'تذكير بعد 10 دقائق لتناول الدواء',
        snoozeTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_reminder_default_v2',
            'تنبيهات الغفوة',
            importance: Importance.max,
            priority: Priority.max,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Snoozed $medId for 10 minutes');
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'med_reminder_default_v2',
      'تذكير بمواعيد الدواء',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      showWhen: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      999,
      'إشعار فوري',
      'النظام يعمل بنجاح! هل تسمع التنبيه؟',
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleTestNotification() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1000,
      '🧪 اختبار المنبه (10 ثواني)',
      'سيعمل المنبه الآن للتأكد من المواعيد المجدولة',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_default_v2',
          'تذكير بمواعيد الدواء',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('Scheduled test notification for $scheduledDate');
  }

  Future<void> showLowStockNotification(int medId, int remaining) async {
    final med = await _db.getMedicationById(medId);
    if (med == null) return;

    await flutterLocalNotificationsPlugin.show(
      medId + 888888, // Unique ID for low stock
      '⚠️ كمية الدواء منخفضة',
      'بقي لديك $remaining حبات فقط من ${med.name}. يرجى إعادة شراء الدواء قريباً.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_default_v2',
          'تحذير نفاذ الكمية',
          importance: Importance.high,
          priority: Priority.high,
          audioAttributesUsage: AudioAttributesUsage.notification,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  Future<void> scheduleNotification(Medication medication) async {
    if (medication.id == null) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Create absolute start time (Anchor)
    final tz.TZDateTime anchor = tz.TZDateTime(
      tz.local,
      medication.year ?? now.year,
      medication.month ?? now.month,
      medication.day ?? now.day,
      medication.hour,
      medication.minute,
    );

    // Select channel based on sound
    final String channelId = medication.sound != null
        ? 'med_reminder_${medication.sound}_v2'
        : 'med_reminder_default_v2';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'تذكير بمواعيد الدواء',
      channelDescription: 'إشعارات تذكير الدواء المجدولة',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: medication.sound != null
          ? RawResourceAndroidNotificationSound(medication.sound!)
          : null,
      showWhen: true,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('action_taken', 'تم التناول ✅', showsUserInterface: true),
        const AndroidNotificationAction('action_snooze', 'غفوة ⏰', showsUserInterface: true),
      ],
    );

    debugPrint('Details for scheduling: $channelId, Sound: ${medication.sound}');

    // If Daily or No Interval
    if (medication.intervalUnit == null || medication.intervalUnit == 'daily') {
      tz.TZDateTime scheduleTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        medication.hour,
        medication.minute,
      );

      // If time is already passed today, move to next occurrence
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      if (medication.endDate == null) {
        // Schedule as repeating daily (indefinite)
        final String dayStamp = '${scheduleTime.year}-${scheduleTime.month.toString().padLeft(2, '0')}-${scheduleTime.day.toString().padLeft(2, '0')}';

        await flutterLocalNotificationsPlugin.zonedSchedule(
          medication.id!,
          '💊 موعد الدواء: ${medication.name}',
          'حان وقت تناول جرعة ${medication.dosage}',
          scheduleTime,
          NotificationDetails(
            android: androidDetails,
            iOS: DarwinNotificationDetails(
              presentSound: true,
              sound: medication.sound != null ? '${medication.sound}.mp3' : null,
              categoryIdentifier: 'med_actions',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: '${medication.id!}:$dayStamp',
        );
        debugPrint('SUCCESS: Scheduled repeating daily for ${medication.name}');
        return;
      }

      // If endDate provided: schedule individual daily occurrences up to endDate
      DateTime end;
      try {
        final parts = medication.endDate!.split('-');
        end = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      } catch (e) {
        end = now.add(const Duration(days: 14));
      }

      tz.TZDateTime current = scheduleTime;
      int idx = 0;
      while (!current.isAfter(tz.TZDateTime(tz.local, end.year, end.month, end.day, 23, 59))) {
        final dayStamp = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
        final notifId = medication.id! * 1000 + idx;
        
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notifId,
            '💊 موعد الدواء: ${medication.name}',
            'حان وقت تناول جرعة ${medication.dosage}',
            current,
            NotificationDetails(
              android: androidDetails,
              iOS: DarwinNotificationDetails(
                presentSound: true,
                sound: medication.sound != null ? '${medication.sound}.mp3' : null,
                categoryIdentifier: 'med_actions',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: '${medication.id!}:$dayStamp',
          );
          idx++;
        } catch (e) {
          debugPrint('Failed to schedule notification $idx for ${medication.name}: $e');
          break; // Stop scheduling if we hit a system limit
        }
        
        current = current.add(const Duration(days: 1));
        if (idx >= 60) break; // Limit to 60 days ahead to prevent hitting system alarm limits
      }

      debugPrint('Scheduled $idx daily occurrences for ${medication.name} until $end');
      return;
    }

    // For interval-based scheduling (minutes/hours/days)
    final int interval = medication.interval ?? 1;
    final unit = medication.intervalUnit;
    final int intervalSeconds = (unit == 'hours') ? interval * 3600 : (unit == 'minutes' ? interval * 60 : interval * 86400);
    
    final List<tz.TZDateTime> occurrences = [];
    // Determine scheduling limit: use endDate if provided, otherwise a default horizon
    tz.TZDateTime limit;
    if (medication.endDate != null) {
      try {
        final parts = medication.endDate!.split('-');
        final end = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        limit = tz.TZDateTime(tz.local, end.year, end.month, end.day, 23, 59);
      } catch (e) {
        limit = now.add(const Duration(days: 14));
      }
    } else {
      final horizonDays = 14; // Schedule for 2 weeks to stay within system limits
      limit = now.add(Duration(days: horizonDays));
    }
    
    // Find first occurrence on or after NOW based on ANCHOR
    final int secondsFromAnchorToNow = now.difference(anchor).inSeconds;
    int intervalsNeeded;
    if (secondsFromAnchorToNow <= 0) {
      intervalsNeeded = 0;
    } else {
      intervalsNeeded = (secondsFromAnchorToNow / intervalSeconds).ceil();
    }

    tz.TZDateTime current = anchor.add(Duration(seconds: intervalsNeeded * intervalSeconds));
    int seq = 0;
    
    while (current.isBefore(limit) || current.isAtSameMomentAs(limit)) {
      occurrences.add(current);
      current = current.add(Duration(seconds: intervalSeconds));
      seq++;
      if (seq >= 50) break; // Limit to 50 occurrences to prevent hitting system alarm limits (500 total)
    }

    int idx = 0;
    for (final occ in occurrences) {
      final notifId = medication.id! * 1000 + idx;
      final occDayStamp = '${occ.year}-${occ.month.toString().padLeft(2, '0')}-${occ.day.toString().padLeft(2, '0')}';
      
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notifId,
          '💊 موعد الدواء: ${medication.name}',
          'حان وقت تناول جرعة ${medication.dosage}',
          occ,
          NotificationDetails(
            android: androidDetails,
            iOS: DarwinNotificationDetails(
              presentSound: true,
              sound: medication.sound != null ? '${medication.sound}.mp3' : null,
              categoryIdentifier: 'med_actions',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '${medication.id!}:$occDayStamp',
        );
        idx++;
      } catch (e) {
        debugPrint('Failed to schedule interval notification $idx for ${medication.name}: $e');
        break; 
      }
    }

    debugPrint('Scheduled $idx occurrences for ${medication.name} (Interval: $interval $unit)');
  }


  Future<void> cancelNotification(int id) async {
    // Cancel primary id
    await flutterLocalNotificationsPlugin.cancel(id);
    // Also cancel scheduled occurrences created with derived ids
    // We try a reasonable range of derived ids
    for (int i = 0; i < 100; i++) {
      final derived = id * 1000 + i;
      await flutterLocalNotificationsPlugin.cancel(derived);
    }
  }
}
