import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/ets/domain/entities/ets.dart';

class LocalNotificationsService {
  LocalNotificationsService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'ets_reminders_channel',
    'Recordatorios ETS',
    description: 'Notificaciones locales para recordar exámenes ETS',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (kIsWeb) {
      return;
    }

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> showEtsReminder(Ets exam) async {
    if (kIsWeb) {
      return;
    }

    await _plugin.show(
      id: _immediateId(exam.id),
      title: 'Recordatorio de ETS',
      body: _buildBody(exam),
      notificationDetails: _notificationDetails(),
      payload: 'ets_${exam.id}_now',
    );
  }

  static Future<DateTime> scheduleEtsReminder(
    Ets exam, {
    required Duration before,
  }) async {
    if (kIsWeb) {
      return DateTime.now();
    }

    final examDate = exam.fecha.toLocal();
    final scheduledDate = examDate.subtract(before);

    if (scheduledDate.isBefore(DateTime.now())) {
      await showEtsReminder(exam);
      return DateTime.now();
    }

    final scheduledTzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: _scheduledId(exam.id, before),
      title: 'Recordatorio de ETS',
      body: _buildScheduledBody(exam, before),
      scheduledDate: scheduledTzDate,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'ets_${exam.id}_${before.inMinutes}',
    );

    return scheduledDate;
  }

  static Future<void> cancelEtsReminders(int examId) async {
    if (kIsWeb) {
      return;
    }

    await _plugin.cancel(
      id: _immediateId(examId),
    );

    await _plugin.cancel(
      id: _scheduledId(examId, const Duration(hours: 1)),
    );

    await _plugin.cancel(
      id: _scheduledId(examId, const Duration(days: 1)),
    );
  }

  static NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'ets_reminders_channel',
      'Recordatorios ETS',
      channelDescription: 'Notificaciones locales para recordar exámenes ETS',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    return const NotificationDetails(
      android: androidDetails,
    );
  }

  static String _buildBody(Ets exam) {
    final localDate = exam.fecha.toLocal();

    return 'Tienes ETS de ${exam.ua}\n'
        'Fecha: ${_twoDigits(localDate.day)}/${_twoDigits(localDate.month)}/${localDate.year}\n'
        'Hora: ${_twoDigits(localDate.hour)}:${_twoDigits(localDate.minute)}\n'
        'Lugar: ${exam.salon} - ${exam.edificio ?? 'Edificio no asignado'}';
  }

  static String _buildScheduledBody(Ets exam, Duration before) {
    final label = before.inDays >= 1
        ? 'mañana'
        : 'en ${before.inHours} hora${before.inHours == 1 ? '' : 's'}';

    return 'Tu ETS de ${exam.ua} será $label.\n${_buildBody(exam)}';
  }

  static int _immediateId(int examId) {
    return examId * 1000;
  }

  static int _scheduledId(int examId, Duration before) {
    return (examId * 1000) + before.inMinutes;
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}