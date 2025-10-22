import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/*
  Where images get saved and fetched from 
  Cannot save images inside flutter becuase flutter storage 
  is no longer free. From my understanding saving images directly in flutter can cause problems becuase 
  images can become quite big in size, which flutter free version dosent really support
*/
class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'djn1g43fc',
    'flutter_upload',
    cache: false,
  );

  // uppload one image
  Future<String> uploadImageToCloudinary(File file) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'images',
      ),
    );
    return response.secureUrl;
  }

  /*
    Upploads images to cloudinary and returns a list of the images urls just uploaded.
  */
  Future<List<String>> uploadImagesToCloudinary(List<File> files) async {
    List<String> urls = [];

    for (File file in files) {
      String url = await uploadImageToCloudinary(file);
      urls.add(url);
    }

    return urls;
  }
}
