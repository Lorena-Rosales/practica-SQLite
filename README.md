# Gestor de Tareas Local (Práctica SQLite)
Aplicación en Flutter de tareas con persistencia local en una base SQLite, multiplataforma y sin servidor. 

## Tecnología de persistencia
Después de realizar la investigación basada en las preguntas del pdf, decidí seleccionar "Drift" junto con "drift_flutter" para guardar las tareas en una base de datos SQLite local.

Algunas razones para escoger Drift fueron:
- Funciona en Android, iOS, Windows, Linux, macOS y web. En nativo usa SQLite directamente y en el navegador usa SQLite compilado a WebAssembly.
- La tabla se escribe como una clase de Dart por lo que si hay errores en el nombre de una columna o en un tipo, el editor avisa antes de ejecutar la app.
- Drift puede "vigilar" una consulta con watch(), por lo que cuando se agrega, edita o se elimina una tarea, la pantalla se refresca automáticamente, es decir que la lista se actualiza sola.

La razón para usar drift_flutter es que proporciona driftDatabase(name: ...), que abre la base en el lugar correcto de cada plataforma:
- **Android, iOS, Windows, Linux y macOS:** Crea un archivo tareas.sqlite en la carpeta de documentos de la app (getApplicationDocumentsDirectory()).
- **Web:** Usa SQLite compilado a WebAssembly y guarda los datos en el almacenamiento del navegador. Para esto se deben agregar en web/ los archivos sqlite3.wasm y drift_worker.js. Ambos archivos se descargaron del repositorio oficial de Drift en GitHub, en la versión que corresponde a la instalada (2.35.4).

**Nota:** Una alternativa que se descartó fue "sqflite", ya que sólo funciona en Android, iOS y macOS por lo que para Windows, Linux y web se requieren paquetes adicionales.

## Diseño de la base de datos
Tabla tareas:

| Campo      | Tipo SQLite | Tipo en Dart (Drift)   | Reglas                                     |
|------------|-------------|------------------------|--------------------------------------------|
| id         | INTEGER     | `int` (`IntColumn`)    | Llave primaria, autoincremental            |
| titulo     | TEXT        | `String` (`TextColumn`)| Obligatorio (NOT NULL)                     |
| completada | INTEGER     | `bool` (`BoolColumn`)  | Obligatorio, por defecto 0                 |

Los títulos vacíos o con solo espacios se rechazan en la aplicación antes de guardar.

Para el campo de "completada" 0 = pendiente y 1 = completada. Drift hace la conversión a booleano automáticamente.

**Identificación de registros:** 
Para identificar a las tareas se utiliza el atributo de id. Este campo es generado de manera automática por SQLite al agregar o insertar una nueva tarea. Este valor es único para cada registro y no se repite ni se reutiliza aun cuando se elimine alguna tarea. Con el id se realizan las operaciones de eliminar, cambiar estado o editar.

## Plataformas
- **Android:** Probada en un celular Samsung Galaxy A21s.
- **Web:** Probada en Chrome (Windows).
- **Windows:** Probada como app de escritorio en Windows 11.
- **iOS y macOS:** Previstas (carpetas incluidas). No se probaron porque requieren una Mac.
- **Linux:** Prevista (carpeta incluida). No se probó.

## Pruebas automáticas
En test/base_datos_test.dart se usa una base SQLite en memoria con el propósito de no afectar los datos guardados en la aplicación:
- Se comprueba que no se guardan tareas con título vacío o con solo espacios.
- Se comprueba que se puede guardar, editar, marcar y eliminar una tarea usando su id.

test/widget_test.dart comprueba que la pantalla inicial se muestra sin errores.

## Cómo ejecutar

Ejecutar lo siguiente:

```
flutter pub get
flutter analyze
flutter test
flutter run
```

Para web, usar un puerto fijo para que el navegador conserve los datos:

```
flutter run -d web-server --web-port 8081
```
y abrir http://localhost:8081 en Chrome.

Nota: El puerto indicado aquí es un ejemplo, puede ser distinto. 

Para Windows (requiere Visual Studio con "Desarrollo para el escritorio con C++"):

```
flutter run -d windows
```

Si se modifica la tabla, se debe regenerar el código de Drift:
```
dart run build_runner build
```
