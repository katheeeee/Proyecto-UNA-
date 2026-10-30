# UNA+ — Integrante 1

Módulo de autenticación, perfil y resumen de actividades para la aplicación móvil de la Universidad Nacional del Altiplano (Puno).

## Alcance del módulo

- Registro de estudiante.
- Inicio de sesión con token persistente.
- Perfil del estudiante: ver, editar y cerrar sesión.
- Pantalla de inicio con resumen de actividades pendientes (hoy y próximos 7 días).

## Ejecución

```bash
cd /home/ceviche/una_plus/integrante_1
flutter pub get
flutter run -d linux
```

Para Android:

```bash
flutter run -d <dispositivo>
flutter build apk --debug
```

## Datos de prueba

- Correo: `estudiante@una.edu.pe`
- Contraseña: `12345678`

## Modo mock y API real

La constante `Constantes.usarDatosMock` en `lib/core/constantes.dart` controla el origen de datos.

- `true`: usa `RepositorioAuthMock`, con 1 segundo de espera por llamada.
- `false`: usa `RepositorioAuthApi` contra `Constantes.apiBaseUrl`.

Cambiar de mock a real requiere únicamente cambiar esa línea cuando el backend Django REST Framework esté disponible.

## Contrato de API previsto

- `POST /auth/registro/`
- `POST /auth/login/`
- `GET /perfil/`
- `PUT /perfil/`
- `GET /actividades/?estado=pendiente`

## Estructura

```text
lib/
  core/
    almacen_sesion.dart
    cliente_dio.dart
    constantes.dart
    formato_fechas.dart
    rutas.dart
    tema.dart
  features/
    auth/
      modelos/
      providers/
      repositorios/
      pantallas/
    perfil/
      providers/
      pantallas/
    inicio/
      providers/
      pantallas/
      widgets/
```

## Funcionalidad por requisito

| Requisito | Archivos previstos |
| --- | --- |
| Registro | `features/auth/pantallas/registro_screen.dart`, `features/auth/providers/auth_provider.dart` |
| Inicio de sesión y token persistente | `features/auth/pantallas/login_screen.dart`, `core/almacen_sesion.dart` |
| Redirección por sesión | `core/rutas.dart` |
| Perfil, edición y cierre de sesión | `features/perfil/` |
| Resumen de actividades | `features/inicio/` |
| Integración HTTP | `core/cliente_dio.dart`, `features/auth/repositorios/repositorio_auth_api.dart` |
| Datos falsos | `features/auth/repositorios/repositorio_auth_mock.dart` |
