import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final String? badgeText;
  final String? imagePath;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    this.badgeText,
    this.imagePath,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    String colorHex = map['buttonColor'] ?? '#0F172A';
    colorHex = colorHex.replaceAll('#', '0xFF');
    
    return ServiceModel(
      id: map['\$id'] ?? '', // Sl7na hadi b \$id
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      buttonText: map['buttonText'] ?? 'إبدأ الآن',
      buttonColor: Color(int.parse(colorHex)),
      badgeText: map['badgeText'],
      imagePath: map['imagePath'],
    );
  }
}
