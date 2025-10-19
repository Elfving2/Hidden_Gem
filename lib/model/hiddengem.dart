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
