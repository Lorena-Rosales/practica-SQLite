import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../data/base_datos.dart';
import '../tema.dart';

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
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 24,
        title: const Text('Gestor de tareas'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) {
            if (restricciones.maxWidth >= 760) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: _construirFormulario()),
                    const SizedBox(width: 24),
                    Expanded(child: _construirLista()),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _construirFormulario(),
                  const SizedBox(height: 16),
                  Expanded(child: _construirLista()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirFormulario() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresApp.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Encabezado('NUEVA TAREA'),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(labelText: 'Nueva tarea'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _agregarTarea,
            icon: const Icon(Icons.add),
            label: const Text('Agregar tarea'),
          ),
        ],
      ),
    );
  }

  Widget _construirLista() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Encabezado('MIS TAREAS'),
          const SizedBox(height: 16),
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
                    child: Text(
                      'Todavía no hay tareas guardadas',
                      style: TextStyle(color: ColoresApp.textoSecundario),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: tareas.length,
                  itemBuilder: (context, index) {
                    final tarea = tareas[index];
                    return _TarjetaTarea(
                      tarea: tarea,
                      alCambiarEstado: (valor) =>
                          _alternarCompletada(tarea, valor),
                      alEditar: () => _editarTarea(tarea),
                      alEliminar: () => _eliminarTarea(tarea),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _TarjetaTarea extends StatelessWidget {
  const _TarjetaTarea({
    required this.tarea,
    required this.alCambiarEstado,
    required this.alEditar,
    required this.alEliminar,
  });

  final Tarea tarea;
  final ValueChanged<bool> alCambiarEstado;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  @override
  Widget build(BuildContext context) {
    final completada = tarea.completada;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completada ? ColoresApp.cian : ColoresApp.borde,
          width: completada ? 2 : 1,
        ),
        boxShadow: completada
            ? [
                BoxShadow(
                  color: ColoresApp.cian.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: completada,
          onChanged: (valor) {
            if (valor != null) {
              alCambiarEstado(valor);
            }
          },
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            color: completada ? ColoresApp.cian : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${completada ? 'Completada' : 'Pendiente'} · ID: ${tarea.id}',
          style: TextStyle(
            color: completada ? ColoresApp.cian : ColoresApp.textoSecundario,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              color: ColoresApp.textoSecundario,
              icon: const Icon(Icons.edit_outlined),
              onPressed: alEditar,
            ),
            IconButton(
              tooltip: 'Eliminar',
              color: ColoresApp.textoSecundario,
              icon: const Icon(Icons.delete_outline),
              onPressed: alEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
