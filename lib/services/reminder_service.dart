import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

/// Handles opt-in due-date reminders. Native iOS reminders are scheduled by
/// the operating system; web reminders can only fire while the app is open.
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;
  Timer? _webReminderTimer;
  List<Task> _webTasks = const [];
  final Set<String> _webRemindedTasks = {};

  Future<void> _initialize() {
    return _initialization ??= _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    tz_data.initializeTimeZones();
    final preferences = await SharedPreferences.getInstance();
    _webRemindedTasks.addAll(
      preferences.getStringList('taskforge.remindedDueTasks') ?? const [],
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'Open TaskForge'),
        windows: WindowsInitializationSettings(
          appName: 'TaskForge',
          appUserModelId: 'com.taskforge.app',
          guid: 'f429e280-5792-4d59-9f39-432d7b0c5a11',
        ),
      ),
    );
  }

  /// Must be called from a user gesture (the Notifications setting).
  Future<bool> requestPermission() async {
    await _initialize();
    final web = _plugin.resolvePlatformSpecificImplementation<
        WebFlutterLocalNotificationsPlugin>();
    if (web != null) {
      if (web.permissionStatus == WebNotificationPermission.granted) {
        return true;
      }
      await web.requestNotificationsPermission();
      return web.permissionStatus == WebNotificationPermission.granted;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  Future<void> syncTasks(
      {required List<Task> tasks, required bool enabled}) async {
    await _initialize();
    _webReminderTimer?.cancel();
    if (!enabled) {
      _webTasks = const [];
      _webRemindedTasks.clear();
      await _plugin.cancelAll();
      return;
    }

    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
      _webTasks = List<Task>.from(tasks);
      final ids = _webTasks
          .where((task) => !task.isCompleted && task.dueDate != null)
          .map(_reminderKey)
          .toSet();
      _webRemindedTasks.removeWhere((key) => !ids.contains(key));
      await _saveWebReminders();
      await _checkWebReminders();
      _webReminderTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _checkWebReminders(),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _scheduleDarwinReminders(tasks);
    }
  }

  Future<void> _scheduleDarwinReminders(List<Task> tasks) async {
    final zoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zoneInfo.identifier));
    await _plugin.cancelAll();

    final pending = tasks
        .where((task) => !task.isCompleted && task.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // iOS keeps a limited number of pending notifications. Schedule the
    // nearest 60 open tasks so reminders stay useful and predictable.
    for (final task in pending.take(60)) {
      final dueDay = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      var reminderAt = dueDay.add(const Duration(hours: 9));
      if (!reminderAt.isAfter(DateTime.now())) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: _notificationId(task.id),
        title: 'Task due today',
        body: task.title,
        scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: task.id,
      );
    }
  }

  Future<void> _checkWebReminders() async {
    if (kIsWeb) {
      final web = _plugin.resolvePlatformSpecificImplementation<
          WebFlutterLocalNotificationsPlugin>();
      if (web == null ||
          web.permissionStatus != WebNotificationPermission.granted) {
        return;
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (await android?.areNotificationsEnabled() == false) return;
    } else {
      return;
    }
    final now = DateTime.now();
    for (final task in _webTasks) {
      if (task.isCompleted || task.dueDate == null) continue;
      final key = _reminderKey(task);
      if (_webRemindedTasks.contains(key)) continue;
      final dueDay = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final reminderAt = dueDay.add(const Duration(hours: 9));
      if (now.isBefore(reminderAt)) continue;

      try {
        await _plugin.show(
          id: _notificationId(key),
          title: 'Task due today',
          body: task.title,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_due_reminders',
              'Task due reminders',
              channelDescription: 'Reminders for tasks due today.',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            macOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: task.id,
        );
        _webRemindedTasks.add(key);
        await _saveWebReminders();
      } catch (error) {
        debugPrint('TaskForge: could not show browser reminder ($error).');
      }
    }
  }

  String _reminderKey(Task task) =>
      '${task.id}-${task.dueDate?.millisecondsSinceEpoch}';

  Future<void> _saveWebReminders() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'taskforge.remindedDueTasks',
      _webRemindedTasks.toList(),
    );
  }

  int _notificationId(String value) => value.codeUnits.fold<int>(
        0,
        (result, unit) => (result * 31 + unit) & 0x7fffffff,
      );
}
