import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hidden_gem/service/coudService.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:image_picker/image_picker.dart';

class AddHiddenGem extends StatefulWidget {
  final selectedPosition;

  const AddHiddenGem({super.key, required this.selectedPosition});

  @override
  State<AddHiddenGem> createState() => _AddHiddenGemState();
}

class _AddHiddenGemState extends State<AddHiddenGem> {
  final List<File> images = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isPublic = true;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    if (images.length == 4) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      images.add(File(picked.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name of Hidden Gem"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Hidden Gem description",
              ),
              maxLines: 5,
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: images.isEmpty
                  ? const Center(child: Text("No images yet"))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(4, (index) {
                        if (index >= images.length) {
                          return Container(
                            width: 58,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            color: Colors.grey[600],
                          );
                        }

                        return Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.file(
                                images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    images.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: const Text("Gallery"),
                ),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera),
                  child: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Switch(
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value;
                    });
                  },
                ),
                Text("Public"),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final description = descriptionController.text;

                List<String> stringImages = await CloudinaryService()
                    .uploadImages(images);

                bool result = await HiddenGemService().uploadHiddenGem(
                  name,
                  description,
                  stringImages,
                  widget.selectedPosition,
                  isPublic,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? "Hidden gem added successfully!"
                          : "Something went wrong!",
                    ),
                  ),
                );

                if (result) {
                  Navigator.of(context).pop(); // close dialog
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
