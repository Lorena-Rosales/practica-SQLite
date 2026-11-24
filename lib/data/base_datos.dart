import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
}