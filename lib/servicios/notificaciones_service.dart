import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionesService {
  final FlutterLocalNotificationsPlugin notificaciones =
      FlutterLocalNotificationsPlugin();

  Future<void> inicializar() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Lima'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificaciones.initialize(settings: settings);
  }

  Future<bool> solicitarPermiso() async {
    final android = notificaciones
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final permitido = await android?.requestNotificationsPermission();

    return permitido ?? false;
  }

  Future<void> activarRecordatorio({
    required int id,
    required String curso,
    required String aula,
    required int dia,
    required int hora,
    required int minuto,
  }) async {
    final ahora = tz.TZDateTime.now(tz.local);

    int diasRestantes = (dia - ahora.weekday + 7) % 7;

    var fecha = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day + diasRestantes,
      hora,
      minuto,
    ).subtract(const Duration(minutes: 10));

    if (!fecha.isAfter(ahora)) {
      fecha = fecha.add(const Duration(days: 7));
    }

    await notificaciones.zonedSchedule(
      id: id,
      title: 'Recordatorio de clase',
      body: '$curso comienza en 10 minutos. Aula: $aula',
      scheduledDate: fecha,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'una_mas_recordatorios',
          'Recordatorios de clases',
          channelDescription: 'Avisos antes del inicio de tus clases',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> desactivarRecordatorio(int id) async {
    await notificaciones.cancel(id: id);
  }
}
