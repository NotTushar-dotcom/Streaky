import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static Function(String)? onNotificationClick;

  /// Get launch details if app was opened via notification click
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return await _notificationsPlugin.getNotificationAppLaunchDetails();
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification settings and timezone mapping.
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone support
    tz.initializeTimeZones();
    try {
      var timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      
      // Common mapping corrections for Indian timezones in some databases
      if (timeZoneName == 'Asia/Calcutta') {
        timeZoneName = 'Asia/Kolkata';
      }
      
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (inner) {
        if (timeZoneName == 'Asia/Kolkata') {
          // If Kolkata failed, try Calcutta as fallback
          tz.setLocalLocation(tz.getLocation('Asia/Calcutta'));
        } else {
          // Otherwise try Kolkata as a safe default for India, or rethrow
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Failed to set local time zone: $e. Defaulting to UTC.');
      tz.setLocalLocation(tz.UTC);
    }

    // Android configurations
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/Darwin configurations
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
        if (response.payload != null && response.payload!.isNotEmpty && onNotificationClick != null) {
          onNotificationClick!(response.payload!);
        }
      },
    );

    // Create Android notification channels explicitly
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_reminders_channel_v2',
          'Streak Reminders',
          description: 'Daily alerts to keep up your habits and streaks.',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'instant_test_channel',
          'Test Notifications',
          description: 'Used to verify notification system.',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;
    debugPrint('NotificationService initialized successfully.');
  }

  /// Request permissions for iOS and Android
  Future<bool> requestPermissions() async {
    // For iOS
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final bool? iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // For Android (specifically Android 13+)
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? androidGranted =
        await androidImplementation?.requestNotificationsPermission();

    debugPrint('NotificationService: requestPermissions iOS: $iosGranted, Android: $androidGranted');
    return (iosGranted ?? false) || (androidGranted ?? false);
  }

  /// Helper to convert a string streakId into a unique 32-bit positive integer
  int _getNotificationId(String streakId) {
    return streakId.hashCode & 0x7FFFFFFF;
  }

  /// Helper to parse reminderTime string (e.g. "8:00 PM", "08:30 AM") to TimeOfDay
  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final meridian = parts[_meridianIndex(parts)].toUpperCase();
        if (meridian == 'PM' && hour < 12) hour += 12;
        if (meridian == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint('Error parsing time "$timeStr": $e');
      return null;
    }
  }

  /// Helper to get the index of meridian (AM/PM) from parts
  int _meridianIndex(List<String> parts) {
    for (int i = 1; i < parts.length; i++) {
      final p = parts[i].toUpperCase();
      if (p == 'AM' || p == 'PM') return i;
    }
    return 1;
  }

  /// Schedule a daily notification for a specific streak.
  Future<void> scheduleStreakReminder({
    required String streakId,
    required String title,
    required String emoji,
    required String timeStr,
  }) async {
    final parsedTime = _parseTime(timeStr);
    if (parsedTime == null) return;

    final id = _getNotificationId(streakId);
    final now = tz.TZDateTime.now(tz.local);
    
    // Construct the schedule time
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String titleText = 'Keep the fire burning! $emoji';
    final String bodyText = 'Your "$title" streak is waiting. Tap to complete it! ⚡';

    final androidDetails = AndroidNotificationDetails(
      'streak_reminders_channel_v2',
      'Streak Reminders',
      channelDescription: 'Daily alerts to keep up your habits and streaks.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        bodyText,
        contentTitle: titleText,
      ),
      showWhen: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: titleText,
        body: bodyText,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        payload: streakId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Notification scheduled exactly for streak "$title" (ID: $id) at $timeStr (tz: ${scheduledDate.toString()})');
    } catch (e) {
      debugPrint('Exact alarms not permitted ($e). Falling back to inexact scheduled notifications.');
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: titleText,
          body: bodyText,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          payload: streakId,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('Notification scheduled inexactly for streak "$title" (ID: $id) at $timeStr (tz: ${scheduledDate.toString()})');
      } catch (innerError) {
        debugPrint('Failed to schedule notification: $innerError');
      }
    }
  }

  /// Schedule a test notification for a specific time (one-shot).
  Future<void> scheduleTestReminder({
    required int id,
    required String title,
    required String emoji,
    required tz.TZDateTime scheduledDate,
  }) async {
    final String titleText = 'Keep the fire burning! $emoji';
    final String bodyText = 'Your "$title" streak is waiting. Tap to complete it! ⚡';

    final androidDetails = AndroidNotificationDetails(
      'streak_reminders_channel_v2',
      'Streak Reminders',
      channelDescription: 'Daily alerts to keep up your habits and streaks.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        bodyText,
        contentTitle: titleText,
      ),
      showWhen: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: titleText,
      body: bodyText,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      payload: title,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('Test notification scheduled for "$title" at ${scheduledDate.toString()}');
  }

  /// Syncs active notifications: cancels any scheduled notification whose streak ID
  /// is not in the list of active streak IDs.
  Future<void> syncActiveNotifications(List<String> activeStreakIds) async {
    final activeIds = activeStreakIds.map(_getNotificationId).toSet();
    try {
      final pendingRequests = await _notificationsPlugin.pendingNotificationRequests();
      for (final request in pendingRequests) {
        if (!activeIds.contains(request.id)) {
          await _notificationsPlugin.cancel(id: request.id);
          debugPrint('Cleaned up orphaned notification ID: ${request.id}');
        }
      }
    } catch (e) {
      debugPrint('Error syncing active notifications: $e');
    }
  }

  /// Show an instant test notification.
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_test_channel',
      'Test Notifications',
      channelDescription: 'Used to verify notification system.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Cancel a scheduled notification for a specific streak.
  Future<void> cancelStreakReminder(String streakId) async {
    final id = _getNotificationId(streakId);
    await _notificationsPlugin.cancel(id: id);
    debugPrint('Notification cancelled for streak ID: $streakId (Notification ID: $id)');
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled.');
  }
}
