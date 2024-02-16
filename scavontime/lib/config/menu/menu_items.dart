import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final IconData icon;

  const MenuItem(
      {required this.title,
      required this.subTitle,
      required this.link,
      required this.icon});
}

const appMenuItems = <MenuItem>[
  MenuItem(
      title: 'Estudiantes',
      subTitle: 'Lista de Estudiantes',
      link: '/student_screen',
      icon: Icons.school),
  MenuItem(
      title: 'Docentes',
      subTitle: 'Lista de docentes',
      link: '/teacher_screen',
      icon: Icons.how_to_reg),
  MenuItem(
      title: 'Asistencia Estudiante',
      subTitle: 'Asistencia de los estudiantes',
      link: '/student-assistance',
      icon: Icons.task),
  MenuItem(
      title: 'Asistencia Docente',
      subTitle: 'Asistencia de los docentes',
      link: '/teacher-assistance',
      icon: Icons.bookmark_added),
  MenuItem(
      title: 'UI Controls + Tiles',
      subTitle: 'Controles',
      link: '/ui-controls',
      icon: Icons.settings),
  MenuItem(
      title: 'Cambiar tema',
      subTitle: 'Cambiar tema de la aplicación',
      link: '/theme-changer',
      icon: Icons.color_lens_outlined),
  MenuItem(
      title: 'Introducción a la aplicación',
      subTitle: 'Pequeño tutorial introductorio',
      link: '/tutorial',
      icon: Icons.accessibility),
  MenuItem(
      title: 'Snackbars y diálogos',
      subTitle: 'Indicadores en pantalla',
      link: '/snackbars',
      icon: Icons.info_outline),
];
