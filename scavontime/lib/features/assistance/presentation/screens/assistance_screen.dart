import 'package:flutter/material.dart';
import 'package:scavontime/features/shared/shared.dart';

class AssistanceScreen extends StatelessWidget {
  const AssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Lista de docentes'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _AssistanceView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo docente'),
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
    return const Center(child: Text('Eres genial!'));
  }
}
