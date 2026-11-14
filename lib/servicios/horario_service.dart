import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HorarioService {
  // Android Emulator: 10.0.2.2
  // Windows: localhost

  static String get baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:3000';
    }

    return 'http://localhost:3000';
  }

  Future<List<Map<String, dynamic>>> obtenerHorarios(int usuarioId) async {
    final url = Uri.parse('$baseUrl/api/horarios/$usuarioId');

    final respuesta = await http.get(url).timeout(const Duration(seconds: 15));

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      final List<dynamic> lista = datos['horarios'];

      return lista
          .map((elemento) => Map<String, dynamic>.from(elemento))
          .toList();
    }

    if (respuesta.statusCode == 404) {
      throw Exception('El estudiante no existe');
    }

    throw Exception('Error al consultar horarios: ${respuesta.statusCode}');
  }
}
