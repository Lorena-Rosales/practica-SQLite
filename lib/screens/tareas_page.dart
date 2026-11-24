import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../data/base_datos.dart';

// Pantalla base SIN persistencia ni operaciones CRUD implementadas.
// Conserva las indicaciones TODO para orientar tu trabajo.
class TareasPage extends StatefulWidget {
  const TareasPage({super.key, required this.baseDatos});

  final BaseDatos baseDatos;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  late final Stream<List<Tarea>> _tareas;

  @override
  void initState() {
    super.initState();
    _tareas = widget.baseDatos.obtenerTareas();
  }

  Future<void> _agregarTarea() async {
    try {
      await widget.baseDatos.guardarTarea(_tituloController.text);
      _tituloController.clear();
    } on ArgumentError catch (e) {
      _mostrarAviso(e.message.toString());
    } catch (e) {
      _mostrarAviso('No se pudo guardar la tarea: $e');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.baseDatos.cambiarEstado(tarea.id, completada);
    } catch (e) {
      _mostrarAviso('No se pudo actualizar la tarea: $e');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    var textoEditado = tarea.titulo;
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextFormField(
          initialValue: tarea.titulo,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
          onChanged: (valor) => textoEditado = valor,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textoEditado),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nuevoTitulo == null) return;
    try {
      await widget.baseDatos.actualizarTitulo(tarea.id, nuevoTitulo);
    } on ArgumentError catch (e) {
      _mostrarAviso(e.message.toString());
    } catch (e) {
      _mostrarAviso('No se pudo editar la tarea: $e');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.baseDatos.eliminarTarea(tarea.id);
    } catch (e) {
      _mostrarAviso('No se pudo eliminar la tarea: $e');
    }
  }

  void _mostrarAviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar las tareas: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(
                      child: Text('Todavía no hay tareas guardadas'),
                    );
                  }
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(tarea, valor);
                              }
                            },
                          ),
                          title: Text(tarea.titulo),
                          subtitle: Text('ID: ${tarea.id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
