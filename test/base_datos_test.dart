import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';

void main() {
  late BaseDatos baseDatos;

  setUp(() {
    baseDatos = BaseDatos(NativeDatabase.memory());
  });

  tearDown(() async {
    await baseDatos.close();
  });

  test('No se guardan tareas con título vacío o solo espacios', () async {
    expect(() => baseDatos.guardarTarea(''), throwsArgumentError);
    expect(() => baseDatos.guardarTarea('    '), throwsArgumentError);

    final tareas = await baseDatos.obtenerTareas().first;
    expect(tareas, isEmpty);
  });

  test('Se guarda, edita, marca y elimina una tarea por su id', () async {
    final id = await baseDatos.guardarTarea('  Estudiar Drift  ');
    final otraId = await baseDatos.guardarTarea('Comprar despensa');

    var tareas = await baseDatos.obtenerTareas().first;
    expect(tareas.length, 2);
    expect(tareas.first.titulo, 'Estudiar Drift');
    expect(tareas.first.completada, isFalse);

    await baseDatos.actualizarTitulo(id, 'Estudiar SQLite');
    await baseDatos.cambiarEstado(id, true);
    expect(() => baseDatos.actualizarTitulo(id, '   '), throwsArgumentError);

    tareas = await baseDatos.obtenerTareas().first;
    expect(tareas.first.titulo, 'Estudiar SQLite');
    expect(tareas.first.completada, isTrue);

    await baseDatos.eliminarTarea(otraId);

    tareas = await baseDatos.obtenerTareas().first;
    expect(tareas.length, 1);
    expect(tareas.single.id, id);
  });
}