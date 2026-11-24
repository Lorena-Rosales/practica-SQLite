import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/tarea.dart';

part 'base_datos.g.dart';

@DataClassName('TareaRegistro')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class BaseDatos extends _$BaseDatos {
  BaseDatos([QueryExecutor? executor]) : super(executor ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return driftDatabase(name: 'tareas');
  }

  Stream<List<Tarea>> obtenerTareas() {
    final consulta = select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return consulta.watch().map((filas) => filas.map(_convertirATarea).toList());
  }

  Future<int> guardarTarea(String titulo) async {
    final tituloLimpio = titulo.trim();
    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: tituloLimpio));
  }

  Future<void> actualizarTitulo(int id, String nuevoTitulo) async {
    final tituloLimpio = nuevoTitulo.trim();
    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(titulo: Value(tituloLimpio)));
  }

  Future<void> cambiarEstado(int id, bool completada) async {
    await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(completada: Value(completada)));
  }

  Future<void> eliminarTarea(int id) async {
    await (delete(tareas)..where((t) => t.id.equals(id))).go();
  }

  Tarea _convertirATarea(TareaRegistro fila) {
    return Tarea(id: fila.id, titulo: fila.titulo, completada: fila.completada);
  }

}