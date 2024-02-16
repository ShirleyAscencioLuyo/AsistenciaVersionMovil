import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scavontime/features/assistance/domain/entities/student.dart';

// Función para obtener la lista de estudiantes desde la API
Future<List<Student>> fetchStudents() async {
  // Realizar una solicitud HTTP GET para obtener la lista de estudiantes
  final response =
      await http.get(Uri.parse('http://localhost:8085/scavontime/student'));

  // Verificar si la solicitud fue exitosa (código de estado 200)
  if (response.statusCode == 200) {
    // Decodificar la respuesta JSON y mapearla a una lista de objetos Student
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Student.fromJson(json)).toList();
  } else {
    // Si la solicitud no fue exitosa, lanzar una excepción
    throw Exception('Error al cargar los estudiantes');
  }
}

// Widget para mostrar la lista de estudiantes
class StudentScreen extends StatefulWidget {
  static const name = 'student_screen';
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Estudiantes'),
        actions: [
          // Botón de icono para la funcionalidad de búsqueda (por implementar)
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: FutureBuilder<List<Student>>(
        // Obtener y mostrar la lista de estudiantes usando un FutureBuilder
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar un indicador de carga mientras se espera los datos
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Mostrar un mensaje de error si hay un error al obtener los datos
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Mostrar la lista de estudiantes usando un widget personalizado
            final students = snapshot.data!;
            return _StudentListView(students: students);
          }
        },
      ),
      // Botón de acción flotante para agregar un nuevo estudiante
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo'),
        icon: const Icon(Icons.add),
        onPressed: () => _showAddStudentForm(context),
      ),
    );
  }

  // Función para mostrar un diálogo para agregar un nuevo estudiante
  void _showAddStudentForm(BuildContext context) async {
    // Construir y mostrar un AlertDialog para agregar un nuevo estudiante
    showDialog(
      context: context,
      builder: (context) {
        // Controladores para manejar la entrada de texto en el formulario
        TextEditingController nameController = TextEditingController();
        TextEditingController lastnameController = TextEditingController();
        TextEditingController emailController = TextEditingController();
        TextEditingController documentTypeController = TextEditingController();
        TextEditingController documentNumberController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Agregar Estudiante'),
          content: Container(
            width: 300.0,
            // Formulario para ingresar la información del estudiante
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: lastnameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                TextField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'Correo electrónico'),
                ),
                TextField(
                  controller: documentTypeController,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de Documento'),
                ),
                TextField(
                  controller: documentNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Número de Documento'),
                ),
              ],
            ),
          ),
          // Acciones para guardar o cancelar el formulario
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Crear un nuevo objeto Student con la información ingresada
                final newStudent = Student(
                  studentId: 0,
                  name: nameController.text,
                  lastname: lastnameController.text,
                  email: emailController.text,
                  documentType: documentTypeController.text,
                  documentNumber: documentNumberController.text,
                  active: 'A',
                );

                try {
                  // Llamar a la API para agregar al nuevo estudiante
                  await addStudent(newStudent);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Estudiante creado con éxito'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  print('Obteniendo estudiantes...');
                  print('Estudiantes obtenidos.');
                } catch (e) {
                  // Manejar errores al agregar un nuevo estudiante
                  print('Error al agregar estudiante: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El estudiante no se ha guardado'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Función para agregar un nuevo estudiante a la API
  Future<void> addStudent(Student student) async {
    // Realizar una solicitud HTTP POST para agregar un nuevo estudiante
    final response = await http.post(
      Uri.parse('http://localhost:8085/scavontime/student/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      // Registrar un mensaje de éxito si el estudiante se agrega correctamente
      print('Estudiante agregado exitosamente');
    } else {
      // Lanzar una excepción si hay un error al agregar al estudiante
      throw Exception(
        'Error al agregar el estudiante. Código de Estado: ${response.statusCode}, Error: ${response.reasonPhrase}',
      );
    }
  }
}

// Widget para mostrar la lista de estudiantes usando ListView
class _StudentListView extends StatelessWidget {
  final List<Student> students;

  const _StudentListView({required this.students});

  @override
  Widget build(BuildContext context) {
    // Construir un ListView de estudiantes usando ListTile
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        // Extraer la información del estudiante para el índice actual
        final student = students[index];
        // Mostrar la información del estudiante en un contenedor estilizado
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text('${student.name} ${student.lastname}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Correo electrónico: ${student.email}'),
                Text('Tipo de Documento: ${student.documentType}'),
                Text('Número de Documento: ${student.documentNumber}'),
              ],
            ),
            onTap: () {
              _showMenuEstudiante(context, student);
            },
            // Menú emergente para acciones adicionales (por implementar)
            trailing: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Editar'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Eliminar'),
                ),
                PopupMenuItem<String>(
                  value: 'details',
                  child: Text('Detalles'),
                ),
              ],
              onSelected: (String value) {
                // Lógica para manejar diferentes opciones de menú (por implementar)
                if (value == 'edit') {
                  // Lógica para editar
                } else if (value == 'delete') {
                  // Lógica para eliminar
                } else if (value == 'details') {
                  // Lógica para ver detalles
                }
              },
            ),
          ),
        );
      },
    );
  }

  // Función para mostrar un menú de acciones adicionales sobre un estudiante
  void _showMenuEstudiante(BuildContext context, Student student) {
    // Implementar lógica para mostrar el menú de opciones adicionales
  }
}