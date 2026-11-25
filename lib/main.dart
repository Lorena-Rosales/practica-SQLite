import 'package:flutter/material.dart';
import 'screens/tareas_page.dart';
import 'data/base_datos.dart';
import 'tema.dart';

void main() {
  final baseDatos = BaseDatos();
  runApp(GestorTareasApp(baseDatos: baseDatos));
}

/// Punto de entrada de la aplicación.
/// La configuración del almacenamiento se agregará como parte de la tarea.
class GestorTareasApp extends StatelessWidget {
  const GestorTareasApp({super.key, required this.baseDatos});

  final BaseDatos baseDatos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: crearTema(),
      home: TareasPage(baseDatos: baseDatos),
    );
  }
}
