import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdCardScreen extends StatefulWidget {
  const IdCardScreen({super.key});

  @override
  State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('id_card_image');
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Permite al usuario subir imagen desde galería o archivos
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_card_image', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = const Text('Aún no has subido tu carnet.\nPresiona el botón abajo para seleccionarlo.', textAlign: TextAlign.center);
    
    if (_imagePath != null) {
      if (kIsWeb) {
        imageWidget = Image.network(_imagePath!);
      } else {
        imageWidget = Image.file(File(_imagePath!));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tu Carnet Digital', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir Carnet (Galería/Archivos)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
