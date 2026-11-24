import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:drift/native.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    final baseDatos = BaseDatos(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(baseDatos: baseDatos));
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await baseDatos.close();
  });
}
