import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'djn1g43fc', // e.g., djn1g43fc
    'flutter_upload',
    cache: false,
  );

  // Upload a single image
  Future<String> uploadImage(File file) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'images',
      ),
    );
    return response.secureUrl;
  }

  Future<List<String>> uploadImages(List<File> files) async {
    List<String> urls = [];

    for (File file in files) {
      String url = await uploadImage(file);
      urls.add(url);
    }

    return urls; // Returns list of URLs
  }
}
