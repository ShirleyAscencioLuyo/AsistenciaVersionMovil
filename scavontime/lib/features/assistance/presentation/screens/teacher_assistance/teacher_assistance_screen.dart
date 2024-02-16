import 'package:flutter/material.dart';
import 'package:scavontime/features/shared/shared.dart';

class TeacherAssistanceScreen extends StatelessWidget {
  static const name = 'teacher_assistance_screen';
  const TeacherAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Asistencia Docente'),
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
    return const Center(child: Text('Asistencia de los Docentes!'));
  }
}
