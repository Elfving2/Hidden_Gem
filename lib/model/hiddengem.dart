/*
  Hidden gem model 
  * id - document id
  * name - name of gem
  * description - description of gem
  * latitude - cordinates for google map so we can pinpoint exactly where gem placed
  * longitude - cordinates for google map so we can pinpoint exactly where gem placed
  * imageUrls - urls of images in saved in data images are from cloudinary
  * ownerId - user document id 
  * isPublic - tells us if gem is public or private vissiblity for user
  * likes - how many likes gem has
*/
class HiddenGem {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String ownerId;
  final bool isPublic;
  final int likes;

  HiddenGem({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.ownerId,
    required this.isPublic,
    required this.likes,
  });
}
