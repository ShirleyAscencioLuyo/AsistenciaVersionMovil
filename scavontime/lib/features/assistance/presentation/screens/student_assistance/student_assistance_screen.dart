import 'package:flutter/material.dart';
import 'package:scavontime/features/shared/shared.dart';

class StudentAssistanceScreen extends StatelessWidget {
  static const name = 'student_assistance_screen';
  const StudentAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Asistencia Estudiante'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _AssistanceView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo'),
        icon: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

class _AssistanceView extends StatelessWidget {
  const _AssistanceView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Asistencias de los Estudiante!'));
  }
}
