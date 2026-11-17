import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/servicio.dart';

class ServicioService {
  // Para emulador Android.
  static const String baseUrl = 'http://127.0.0.1:8000/api/servicios/';

  Future<List<Servicio>> obtenerServicios() async {
    final respuesta = await http.get(Uri.parse(baseUrl));

    if (respuesta.statusCode == 200) {
      final List datos = jsonDecode(respuesta.body);
      return datos.map((item) => Servicio.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar servicios');
    }
  }
}
