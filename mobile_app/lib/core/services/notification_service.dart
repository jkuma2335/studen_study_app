import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:mobile_app/features/subjects/domain/schedule_model.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (Android 13+)
    await _requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Android 13+ permissions
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS permissions are requested via DarwinInitializationSettings
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    // You can navigate to a specific screen here
  }

  /// Schedule a class reminder notification
  /// 
  /// Schedules a notification 15 minutes before the class starts
  /// Repeats weekly on the same day and time
  Future<void> scheduleClassReminder(
    ScheduleItem item,
    String subjectName,
  ) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Parse day of week
      final dayOfWeek = _parseDayOfWeek(item.dayOfWeek);
      if (dayOfWeek == null) {
        print('Invalid day of week: ${item.dayOfWeek}');
        return;
      }

      // Parse start time
      final timeParts = item.startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Get the next occurrence of this day and time
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = _getNextOccurrence(now, dayOfWeek, hour, minute);

      // Schedule notification 15 minutes before class
      final notificationTime = scheduledDate.subtract(const Duration(minutes: 15));

      // Only schedule if the notification time is in the future
      if (notificationTime.isBefore(now)) {
        // If the notification time has passed, schedule for next week
        final nextWeek = notificationTime.add(const Duration(days: 7));
        await _scheduleNotification(
          id: item.id.hashCode, // Use schedule ID hash as notification ID
          title: 'Class Reminder',
          body: '$subjectName class starts in 15 minutes!${item.location != null ? ' @ ${item.location}' : ''}',
          scheduledDate: nextWeek,
          dayOfWeek: dayOfWeek,
          hour: hour,
          minute: minute,
        );
      } else {
        await _scheduleNotification(
          id: item.id.hashCode,
          title: 'Class Reminder',
          body: '$subjectName class starts in 15 minutes!${item.location != null ? ' @ ${item.location}' : ''}',
          scheduledDate: notificationTime,
          dayOfWeek: dayOfWeek,
          hour: hour,
          minute: minute,
        );
      }
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  /// Schedule a notification with weekly repeat
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'class_reminders',
      'Class Reminders',
      channelDescription: 'Notifications for upcoming classes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification with weekly repeat
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Get the next occurrence of a specific day and time
  tz.TZDateTime _getNextOccurrence(
    tz.TZDateTime now,
    int dayOfWeek,
    int hour,
    int minute,
  ) {
    // Calculate days until next occurrence
    int daysUntil = (dayOfWeek - now.weekday) % 7;
    if (daysUntil == 0) {
      // If it's the same day, check if time has passed
      final todayAtTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (todayAtTime.isBefore(now)) {
        // Time has passed today, schedule for next week
        daysUntil = 7;
      }
    }

    final nextDate = now.add(Duration(days: daysUntil));
    return tz.TZDateTime(
      tz.local,
      nextDate.year,
      nextDate.month,
      nextDate.day,
      hour,
      minute,
    );
  }

  /// Parse day of week string to int (1 = Monday, 7 = Sunday)
  int? _parseDayOfWeek(String dayOfWeek) {
    final normalized = dayOfWeek.toLowerCase();
    switch (normalized) {
      case 'mon':
      case 'monday':
        return 1;
      case 'tue':
      case 'tuesday':
        return 2;
      case 'wed':
      case 'wednesday':
        return 3;
      case 'thu':
      case 'thursday':
        return 4;
      case 'fri':
      case 'friday':
        return 5;
      case 'sat':
      case 'saturday':
        return 6;
      case 'sun':
      case 'sunday':
        return 7;
      default:
        return null;
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// Schedule assignment reminder notifications
  /// 
  /// Schedules two notifications:
  /// - 24 hours before due date
  /// - 3 hours before due date
  Future<void> scheduleAssignmentReminders(Assignment assignment) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      final dueDate = tz.TZDateTime.from(assignment.dueDate, tz.local);

      // Only schedule if due date is in the future
      if (dueDate.isBefore(now)) {
        return;
      }

      // Cancel any existing reminders for this assignment
      await _notifications.cancel(assignment.id.hashCode);
      await _notifications.cancel(assignment.id.hashCode + 1);

      // Schedule 24 hours before
      final reminder24h = dueDate.subtract(const Duration(hours: 24));
      if (reminder24h.isAfter(now)) {
        await _notifications.zonedSchedule(
          assignment.id.hashCode,
          'Assignment Due Soon',
          "Assignment '${assignment.title}' is due in 24 hours!",
          reminder24h,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'assignment_reminders',
              'Assignment Reminders',
              channelDescription: 'Notifications for upcoming assignments',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      // Schedule 3 hours before
      final reminder3h = dueDate.subtract(const Duration(hours: 3));
      if (reminder3h.isAfter(now)) {
        await _notifications.zonedSchedule(
          assignment.id.hashCode + 1,
          'Assignment Due Soon',
          "Assignment '${assignment.title}' is due in 3 hours!",
          reminder3h,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'assignment_reminders',
              'Assignment Reminders',
              channelDescription: 'Notifications for upcoming assignments',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      print('Error scheduling assignment reminders: $e');
    }
  }

  /// Cancel assignment reminders
  Future<void> cancelAssignmentReminders(String assignmentId) async {
    await _notifications.cancel(assignmentId.hashCode);
    await _notifications.cancel(assignmentId.hashCode + 1);
  }
}

