class HiddenGem {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;

  HiddenGem({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
  });

  String displayValues() {
    return (imageUrls[0]);
  }
}
