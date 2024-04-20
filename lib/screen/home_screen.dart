import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> imageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImage() async {
    XFile? img = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      _uploadToFirebase(File(img.path));
    }
  }

  Future<void> _uploadToFirebase(image) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Define a storage reference
      Reference storage = FirebaseStorage.instance
          .ref()
          .child('Images/${DateTime.now().millisecondsSinceEpoch}.png');

      // Upload the image file to Firebase Storage
      await storage.putFile(image).whenComplete(() {
        Fluttertoast.showToast(msg: 'Image uploaded to Firebase');
      });

      // Retrieve the download URL of the uploaded image
      imageUrls.add(await storage.getDownloadURL());
    } catch (e) {
      // Handle errors if any
      print('Error occurred $e');

      Fluttertoast.showToast(msg: 'Failed to upload image: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Firebase',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              if (imageUrls.isEmpty) {
                return const Icon(Icons.person);
              } else {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                );
              }
            },
          ),
          const SizedBox(
            height: 40,
          ),
          if (isLoading)
            const SpinKitThreeBounce(
              color: Colors.black,
              size: 20,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          _pickImage();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
