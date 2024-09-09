import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    _loadImages();
    super.initState();
  }

  Future<void> _loadImages() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePaths = sharedPrefs.getStringList('imagePaths') ?? [];
    });
  }

  Future<void> _deleteImages(int index) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _imagePaths.removeAt(index);
    await sharedPrefs.setStringList('imagePaths', _imagePaths);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CAMERA APP',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: _imagePaths.isEmpty
          ? const Center(child: Text('No images found'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(
                      File(_imagePaths[index]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 5,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          _deleteImages(index);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red.shade900,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImageFromCamera();
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.blueGrey.shade400,
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white60,
        ),
      ),
    );
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final sharedPrefs = await SharedPreferences.getInstance();
      List<String> imagePaths = sharedPrefs.getStringList('imagePaths') ?? [];
      imagePaths.add(image.path);
      await sharedPrefs.setStringList('imagePaths', imagePaths);
    }
    _loadImages();
  }
}
