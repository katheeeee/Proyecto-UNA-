class Constantes {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
  static const bool usarDatosMock = bool.fromEnvironment(
    'USAR_MOCK',
    defaultValue: false,
  );
  static const Duration retrasoMock = Duration(seconds: 1);
  static const int longitudMinimaContrasena = 8;
  static const String correoPrueba = 'estudiante@una.edu.pe';
  static const String contrasenaPrueba = '12345678';

  static const String rutaRegistro = '/auth/registro/';
  static const String rutaLogin = '/auth/login/';
  static const String rutaRefresh = '/auth/token/refresh/';
  static const String rutaPerfil = '/perfil/';
  static const String rutaActividades = '/actividades/?estado=pendiente';
}
