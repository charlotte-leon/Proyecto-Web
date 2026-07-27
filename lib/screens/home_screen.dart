import 'package:flutter/material.dart';
import '../models/announcement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Data para anuncios (ahora mutable)
  final List<Announcement> announcements = [
    Announcement(
      title: 'Conferencia de IA',
      faculty: 'Ingeniería Civil',
      date: '25 Jul 2026',
      description: 'Únete a la conferencia sobre el impacto de la Inteligencia Artificial.',
    ),
    Announcement(
      title: 'Feria de Emprendimiento',
      faculty: 'Ciencias Empresariales',
      date: '28 Jul 2026',
      description: 'Feria de proyectos de los estudiantes de la facultad.',
    ),
  ];

  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final facultyController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Notificación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: facultyController,
                  decoration: const InputDecoration(labelText: 'Facultad'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    announcements.insert(
                      0, // Agrega la notificación arriba
                      Announcement(
                        title: titleController.text,
                        faculty: facultyController.text.isEmpty ? 'General' : facultyController.text,
                        date: 'Hace un momento',
                        description: descController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Publicar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Para no solapar el fondo del Scaffold principal
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: announcements.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ann = announcements[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text(
              ann.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(ann.description),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ann.faculty, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    Text(ann.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        tooltip: 'Añadir Notificación',
        child: const Icon(Icons.add),
      ),
    );
  }
}
