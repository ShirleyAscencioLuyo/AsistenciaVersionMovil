import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scavontime/features/shared/shared.dart';
import 'package:http/http.dart' as http;
import 'package:scavontime/features/assistance/domain/entities/teacher.dart';
import 'package:scavontime/features/assistance/presentation/screens/teacher/teacher_form.dart';
import 'package:scavontime/features/assistance/presentation/screens/teacher/teacher_form_edit.dart';

class TeacherScreen extends StatefulWidget {
  static const name = 'teacher_screen';
  const TeacherScreen({Key? key}) : super(key: key);

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Teacher>> teachers;
  final TextEditingController _searchController = TextEditingController();
  String _selectedDocumentType = '';
  bool _isSwitched = true;

  List<Teacher> filterTeachers(List<Teacher> teachers, String query) {
    return teachers.where((teacher) {
      return (teacher.documentNumber.contains(query) ||
              teacher.lastname.contains(query) ||
              teacher.name.contains(query)) &&
          (_selectedDocumentType.isEmpty ||
              teacher.documentType.nameDocument.trim() ==
                  _selectedDocumentType.trim());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    teachers = fetchTeachers(_isSwitched);
  }

  Future<List<Teacher>> fetchTeachers(bool isActive) async {
    final String url = isActive
        ? 'http://192.168.1.47:8085/scavontime/teacher'
        : 'http://192.168.1.47:8085/scavontime/teacher/I';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Teacher> teachers =
          data.map((json) => Teacher.fromJson(json)).toList();

      teachers.sort((a, b) => a.lastname.compareTo(b.lastname));

      return teachers;
    } else {
      throw Exception('Error al cargar los profesores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lista de Docentes',
              style: TextStyle(fontSize: 18.0),
            ),
            Switch(
              value: _isSwitched,
              onChanged: (value) {
                setState(() {
                  _isSwitched = value;
                  teachers = fetchTeachers(_isSwitched);
                });
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar por Número Doc, Nombres y apellidos',
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 12.0),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80.0,
                  child: DropdownButton<String>(
                    value: _selectedDocumentType.isNotEmpty
                        ? _selectedDocumentType
                        : null,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    hint: const Text('Tipo Doc.',
                        style: TextStyle(fontSize: 10.0)),
                    iconSize: 18.0,
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDocumentType = newValue!;
                      });
                    },
                    items: <String>['Tipo Doc', 'DNI', 'CE']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value == 'Tipo Doc' ? '' : value,
                        child: Text(value, style: TextStyle(fontSize: 10.0)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Teacher>>(
              future: teachers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Teacher> teacherList = snapshot.data!;
                  List<Teacher> filteredTeachers =
                      filterTeachers(teacherList, _searchController.text);

                  filteredTeachers
                      .sort((a, b) => a.lastname.compareTo(b.lastname));

                  return ListView.builder(
                    itemCount: filteredTeachers.length,
                    itemBuilder: (context, index) {
                      Teacher teacher = filteredTeachers[index];
                      return TeacherCard(
                        teacher: teacher,
                        isSwitched: _isSwitched,
                        onReactivate: () =>
                            _showReactivateConfirmationDialog(context, teacher),
                        onDelete: () =>
                            _showDeleteConfirmationDialog(context, teacher),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo', style: TextStyle(fontSize: 14.0)),
        icon: const Icon(Icons.add, size: 18.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeacherForm()),
          );
        },
      ),
    );
  }

  void _showReactivateConfirmationDialog(
      BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reactivar profesor'),
          content: Text('¿Está seguro de reactivar a este profesor?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _reactivateTeacher(teacher);
                Navigator.pop(context);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _reactivateTeacher(Teacher teacher) async {
    final String url =
        'http://192.168.1.47:8085/scavontime/teacher/active/${teacher.id}';

    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      _showAlert('El docente se ha reactivado con éxito', Colors.green);
    } else {
      _showAlert('El docente no ha sido reactivado', Colors.red);
    }

    // Recargar la lista después de la reactivación, independientemente del resultado
    setState(() {
      teachers = fetchTeachers(_isSwitched);
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar docente'),
          content: Text('¿Está seguro de eliminar a este docente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteTeacher(teacher);
                Navigator.pop(context);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTeacher(Teacher teacher) async {
    final String url =
        'http://192.168.1.47:8085/scavontime/teacher/inactive/${teacher.id}';

    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      _showAlert('El docente se ha eliminado correctamente', Colors.green);
    } else {
      _showAlert('Error al eliminar el docente', Colors.red);
    }

    setState(() {
      teachers = fetchTeachers(_isSwitched);
    });
  }

  void _showAlert(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class TeacherCard extends StatelessWidget {
  const TeacherCard(
      {Key? key,
      required this.teacher,
      required this.isSwitched,
      required this.onReactivate,
      required this.onDelete})
      : super(key: key);

  final Teacher teacher;
  final bool isSwitched;
  final VoidCallback onReactivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${teacher.lastname} ${teacher.name}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                      'Tipo de documento: ${teacher.documentType.nameDocument} (${teacher.documentType.description})'),
                  Text('Numero de documento: ${teacher.documentNumber}'),
                  Text('Telefono: ${teacher.cellphone}'),
                  Text('Email: ${teacher.email}'),
                  Text('Fec. Nacimiento: ${teacher.birthdate}'),
                  Text(
                      'Ubigeo: ${teacher.ubigeo.department}, ${teacher.ubigeo.province}, ${teacher.ubigeo.district}'),
                  Text('Tipo de cargo: ${teacher.typeCharge}'),
                  Text('Tipo de condición: ${teacher.typeCondition}'),
                  Text('Hrs. de trabajo: ${teacher.workday}'),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'reactivate') {
                  onReactivate();
                } else if (value == 'delete') {
                  onDelete();
                } else if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherFormEdit(teacherId: teacher.id),
                    ),
                  );
                }
              },
              itemBuilder: (context) => isSwitched
                  ? [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.green),
                            SizedBox(width: 8.0),
                            Text('Editar',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8.0),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ]
                  : [
                      PopupMenuItem<String>(
                        value: 'reactivate',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 8.0),
                            Text('Reactivar',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
