import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hidden_gem/service/coudService.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:image_picker/image_picker.dart';

HiddenGemService hiddenGemService = HiddenGemService();
CloudinaryService cloudinaryService = CloudinaryService();

class addHiddenGem extends StatefulWidget {
  final selectedPosition;

  const addHiddenGem({super.key, required this.selectedPosition});

  @override
  State<addHiddenGem> createState() => _AddHiddenGemState();
}

class _AddHiddenGemState extends State<addHiddenGem> {
  final List<File> images = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isPublic = true;

  @override
  void dispose() {
    // Dispose controllers when going to another page
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    // If there are 4 images you cant add more 4 is max
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
              decoration: const InputDecoration(hintText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
              maxLines: 3,
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: displayImages(images, context),
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
            const SizedBox(height: 20),
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

                String validate = hiddenGemService.validateGem(
                  name,
                  description,
                  images,
                );

                if (validate.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Missing information'),
                      content: Text(validate),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                bool result = true;

                /*
                  Trying to uppload images to cloudinary
                  if sucess display sucess text 
                  else display something went wrong
                */
                try {
                  List<String> imageUrls = await cloudinaryService
                      .uploadImagesToCloudinary(images);
                  await hiddenGemService.uploadHiddenGem(
                    name,
                    description,
                    imageUrls,
                    widget.selectedPosition,
                    isPublic,
                  );
                } catch (e) {
                  result = false;
                }

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
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Display images if there are any else display this 
  TEXT widget = No image choosen
  If user hasnt picked any images yet we dont load "image box" when atleast one image is picked
  we load the image box there is a limit of four images per post
*/
  Widget displayImages(List<File> images, BuildContext context) {
    if (images.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(4, (index) {
          log("Images Length: ${images.length}");
          log("Index: ${index}");
          if (index >= images.length) {
            return Container(
              width: 58,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.grey[600],
            );
          }

          /* 
            Images display "box" can remove image by pressing red x
            to small?
          */
          return Stack(
            children: [
              Container(
                width: 60,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Image.file(images[index], fit: BoxFit.cover),
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
                  child: const Icon(Icons.close, color: Colors.red, size: 20),
                ),
              ),
            ],
          );
        }),
      );
    }
    return const Center(child: Text("No image choosen"));
  }
}
