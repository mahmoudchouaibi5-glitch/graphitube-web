class AppService {
  final String id;
  final String title;
  final String description;
  final String? imagePath;
  final String? badgeText;
  final String buttonText;
  final String buttonColor;

  AppService({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.badgeText,
    required this.buttonText,
    required this.buttonColor,
  });

  factory AppService.fromMap(Map<String, dynamic> map) {
    return AppService(
      id: map['\$id'] ?? '', // Sl7na hadi b \$id o z-dna fallback khawi
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
      badgeText: map['badgeText'],
      buttonText: map['buttonText'] ?? 'إبدأ الآن',
      buttonColor: map['buttonColor'] ?? '#0F172A',
    );
  }
}
