import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/review_notification_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

@LazySingleton(as: ReviewNotificationScheduler)
class LocalReviewNotificationScheduler implements ReviewNotificationScheduler {
  LocalReviewNotificationScheduler(
    this._reviewRepository,
    this._settingsRepository,
  );

  static const _notificationId = 4101;
  static const _reminderHour = 9;
  static const _channelId = 'review_reminders';

  final ReviewRepository _reviewRepository;
  final SettingsRepository _settingsRepository;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!_isSupported) return;

    timezone_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
    } on Object {
      // UTC is a safe fallback when the platform timezone is unavailable.
    }

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<void> requestPermission() async {
    await initialize();
    if (!_isSupported) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  @override
  Future<void> sync() async {
    await initialize();
    if (!_isSupported) return;

    await _notifications.cancel(id: _notificationId);
    final settings = await _settingsRepository.getSettings();
    if (!settings.reviewNotificationsEnabled) return;

    final dueCount = await _reviewRepository.dueCount();
    if (dueCount == 0) return;

    final now = timezone.TZDateTime.now(timezone.local);
    var next = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      _reminderHour,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _notifications.zonedSchedule(
      id: _notificationId,
      title: 'LinguaPages review',
      body: '$dueCount cards are waiting for review.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Review reminders',
          channelDescription: 'Daily reminders for due vocabulary cards',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'review',
    );
  }
}
