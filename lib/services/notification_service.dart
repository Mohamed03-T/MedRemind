import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<VoidCallback> _dataChangedListeners = [];

  void addDataChangedListener(VoidCallback listener) {
    _dataChangedListeners.add(listener);
  }

  void removeDataChangedListener(VoidCallback listener) {
    _dataChangedListeners.remove(listener);
  }

  void _notifyDataChanged() {
    for (final l in List<VoidCallback>.from(_dataChangedListeners)) {
      try {
        l();
      } catch (e) {
        debugPrint('DataChanged listener error: $e');
      }
    }
  }

  /// Public API to notify listeners that underlying data changed (completions/stock)
  void notifyDataChanged() => _notifyDataChanged();
  static const MethodChannel _batteryChannel = MethodChannel('com.mohamed.medremind/battery');

  Future<String> _getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCode') ?? 'ar';
  }

  Future<bool> _getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundEnabled') ?? true;
  }

  String _t(String key, String lang, {Map<String, String>? args}) {
    final Map<String, Map<String, String>> translations = {
      'ar': {
        'snooze_title': '⏰ غفوة: موعد دواء',
        'snooze_body': 'تذكير بعد 10 دقائق لتناول الدواء',
        'low_stock_title': '⚠️ كمية الدواء منخفضة',
        'low_stock_body': 'بقي لديك {remaining} من {name}. يرجى إعادة شراء الدواء قريباً.',
        'med_time_title': '💊 موعد الدواء: {name}',
        'med_time_body': 'حان وقت تناول جرعة {dosage}',
        'action_taken': 'تم التناول ✅',
        'action_snooze': 'غفوة ⏰',
        'channel_name': 'تذكير بمواعيد الدواء',
        'channel_desc': 'إشعارات تذكير الدواء المجدولة',
        'test_title': 'إشعار فوري',
        'test_body': 'النظام يعمل بنجاح! هل تسمع التنبيه؟',
        'snooze_channel': 'تنبيهات الغفوة',
        'stock_channel': 'تحذير نفاذ الكمية',
        'default': 'الافتراضي',
        'soft_bell': 'تنبيه هادئ',
        'loud_alarm': 'تنبيه قوي',
        'glass_ping': 'رنين زجاجي',
        'echo_chime': 'صدى الجرس',
        'crystal_bell': 'جرس كريستال',
        'chan_prefix': 'تذكير الدواء',
        'chan_desc_prefix': 'إشعارات تذكير الدواء بنغمة',
      },
      'en': {
        'snooze_title': '⏰ Snooze: Medication Time',
        'snooze_body': 'Reminder after 10 minutes to take medication',
        'low_stock_title': '⚠️ Low Medication Stock',
        'low_stock_body': 'You have only {remaining} of {name} left. Please restock soon.',
        'med_time_title': '💊 Medication Time: {name}',
        'med_time_body': 'Time to take your dose of {dosage}',
        'action_taken': 'Taken ✅',
        'action_snooze': 'Snooze ⏰',
        'channel_name': 'Medication Reminders',
        'channel_desc': 'Scheduled medication reminders',
        'test_title': 'Instant Notification',
        'test_body': 'System is working successfully! Do you hear the alert?',
        'snooze_channel': 'Snooze Alerts',
        'stock_channel': 'Stock Warning',
        'default': 'Default',
        'soft_bell': 'Soft Bell',
        'loud_alarm': 'Loud Alarm',
        'glass_ping': 'Glass Ping',
        'echo_chime': 'Echo Chime',
        'crystal_bell': 'Crystal Bell',
        'chan_prefix': 'Med Reminder',
        'chan_desc_prefix': 'Medication reminders with sound',
      }
    };
    
    String text = translations[lang]?[key] ?? translations['ar']![key]!;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

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

    final lang = await _getLang();
    final List<Map<String, String>> channels = [
      {'id': 'med_reminder_default_v3', 'name': _t('default', lang), 'sound': 'default'},
      {'id': 'med_reminder_soft_bell_v3', 'name': _t('soft_bell', lang), 'sound': 'soft_bell'},
      {'id': 'med_reminder_loud_alarm_v3', 'name': _t('loud_alarm', lang), 'sound': 'loud_alarm'},
      {'id': 'med_reminder_glass_ping_v3', 'name': _t('glass_ping', lang), 'sound': 'glass_ping'},
      {'id': 'med_reminder_echo_chime_v3', 'name': _t('echo_chime', lang), 'sound': 'echo_chime'},
      {'id': 'med_reminder_crystal_bell_v3', 'name': _t('crystal_bell', lang), 'sound': 'crystal_bell'},
    ];

    for (var chan in channels) {
      await androidPlugin?.createNotificationChannel(AndroidNotificationChannel(
        chan['id']!,
        '${_t('chan_prefix', lang)} (${chan['name']})',
        description: '${_t('chan_desc_prefix', lang)} ${chan['name']}',
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
      _notifyDataChanged();
    } else if (details.actionId == 'action_snooze') {
      // Reschedule in 10 minutes
      final now = tz.TZDateTime.now(tz.local);
      final snoozeTime = now.add(const Duration(minutes: 10));
      final lang = await _getLang();
      final soundEnabled = await _getSoundEnabled();
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        medId + 999999, // Unique ID for snooze
        _t('snooze_title', lang),
        _t('snooze_body', lang),
        snoozeTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'med_reminder_default_v3',
            _t('snooze_channel', lang),
            importance: Importance.max,
            priority: Priority.max,
            playSound: soundEnabled,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Snoozed $medId for 10 minutes');
    }
  }

  Future<void> showTestNotification() async {
    final soundEnabled = await _getSoundEnabled();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'med_reminder_default_v3',
      'تذكير بمواعيد الدواء',
      importance: Importance.max,
      priority: Priority.max,
      playSound: soundEnabled,
      showWhen: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    final NotificationDetails platformChannelSpecifics =
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
    final soundEnabled = await _getSoundEnabled();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1000,
      '🧪 اختبار المنبه (10 ثواني)',
      'سيعمل المنبه الآن للتأكد من المواعيد المجدولة',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_default_v3',
          'تذكير بمواعيد الدواء',
          importance: Importance.max,
          priority: Priority.max,
          playSound: soundEnabled,
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
    final lang = await _getLang();
    final soundEnabled = await _getSoundEnabled();

    await flutterLocalNotificationsPlugin.show(
      medId + 888888, // Unique ID for low stock
      _t('low_stock_title', lang),
      _t('low_stock_body', lang, args: {'remaining': remaining.toString(), 'name': med.name}),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_default_v3',
          _t('stock_channel', lang),
          importance: Importance.high,
          priority: Priority.high,
          playSound: soundEnabled,
          audioAttributesUsage: AudioAttributesUsage.notification,
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
    );
  }

  Future<void> scheduleNotification(Medication medication) async {
    if (medication.id == null) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final lang = await _getLang();
    final soundEnabled = await _getSoundEnabled();
    
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
        ? 'med_reminder_${medication.sound}_v3'
        : 'med_reminder_default_v3';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _t('channel_name', lang),
      channelDescription: _t('channel_desc', lang),
      importance: Importance.max,
      priority: Priority.max,
      playSound: soundEnabled,
      sound: medication.sound != null
          ? RawResourceAndroidNotificationSound(medication.sound!)
          : null,
      showWhen: true,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('action_taken', _t('action_taken', lang), showsUserInterface: true),
        AndroidNotificationAction('action_snooze', _t('action_snooze', lang), showsUserInterface: true),
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
          _t('med_time_title', lang, args: {'name': medication.name}),
          _t('med_time_body', lang, args: {'dosage': medication.dosage}),
          scheduleTime,
          NotificationDetails(
            android: androidDetails,
            iOS: DarwinNotificationDetails(
              presentSound: soundEnabled,
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
            _t('med_time_title', lang, args: {'name': medication.name}),
            _t('med_time_body', lang, args: {'dosage': medication.dosage}),
            current,
            NotificationDetails(
              android: androidDetails,
              iOS: DarwinNotificationDetails(
                presentSound: soundEnabled,
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

    // For interval-based scheduling (minutes/hours/days/months)
    final int interval = medication.interval ?? 1;
    final unit = medication.intervalUnit;
    
    // Note: for months we use an approximation for seconds, but we handle it better in the loop
    final int intervalSeconds = (unit == 'hours') 
        ? interval * 3600 
        : (unit == 'minutes' 
            ? interval * 60 
            : (unit == 'days' ? interval * 86400 : interval * 30 * 86400));
    
    final List<tz.TZDateTime> occurrences = [];
    // Determine scheduling limit: use endDate if provided, otherwise a default horizon
    tz.TZDateTime limit;
    if (medication.endDate != null) {
      try {
        final parts = medication.endDate!.split('-');
        final end = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        limit = tz.TZDateTime(tz.local, end.year, end.month, end.day, 23, 59);
      } catch (e) {
        limit = now.add(const Duration(days: 30)); // 1 month horizon if error
      }
    } else {
      final horizonDays = 60; // Increased horizon for months/days
      limit = now.add(Duration(days: horizonDays));
    }
    
    // Find first occurrence on or after NOW based on ANCHOR
    tz.TZDateTime current;
    if (unit == 'months') {
      current = anchor;
      while (current.isBefore(now)) {
        current = tz.TZDateTime(tz.local, current.year, current.month + interval, current.day, current.hour, current.minute);
      }
    } else {
      final int secondsFromAnchorToNow = now.difference(anchor).inSeconds;
      int intervalsNeeded = (secondsFromAnchorToNow <= 0) ? 0 : (secondsFromAnchorToNow + intervalSeconds - 1) ~/ intervalSeconds;
      current = anchor.add(Duration(seconds: intervalsNeeded * intervalSeconds));
    }

    int seq = 0;
    while (current.isBefore(limit) || current.isAtSameMomentAs(limit)) {
      occurrences.add(current);
      if (unit == 'months') {
        current = tz.TZDateTime(tz.local, current.year, current.month + interval, current.day, current.hour, current.minute);
      } else {
        current = current.add(Duration(seconds: intervalSeconds));
      }
      seq++;
      if (seq >= 50) break; 
    }

    int idx = 0;
    for (final occ in occurrences) {
      final notifId = medication.id! * 1000 + idx;
      final occDayStamp = '${occ.year}-${occ.month.toString().padLeft(2, '0')}-${occ.day.toString().padLeft(2, '0')}';
      
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notifId,
          _t('med_time_title', lang, args: {'name': medication.name}),
          _t('med_time_body', lang, args: {'dosage': medication.dosage}),
          occ,
          NotificationDetails(
            android: androidDetails,
            iOS: DarwinNotificationDetails(
              presentSound: soundEnabled,
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
