 import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'horario_screen.dart';
import 'notas_screen.dart';
import 'recordatorios_screen.dart';
import 'tareas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HorarioScreen(),
    TareasScreen(),
    RecordatoriosScreen(),
    NotasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 72,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFDEE9FF),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    );
                  }
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7B8794),
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: Color(0xFF1E3A5F),
                      size: 24,
                    );
                  }
                  return const IconThemeData(
                    color: Color(0xFF7B8794),
                    size: 22,
                  );
                },
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'Horario',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_outlined),
                  selectedIcon: Icon(Icons.task_alt),
                  label: 'Tareas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.alarm_outlined),
                  selectedIcon: Icon(Icons.alarm),
                  label: 'Recordatorios',
                ),
                NavigationDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt),
                  label: 'Notas',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}