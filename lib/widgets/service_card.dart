import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String? imagePath;
  final Gradient? gradient;
  final String? badgeText;
  final IconData? floatingIcon;
  final String title;
  final String? description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const ServiceCard({
    super.key,
    this.imagePath,
    this.gradient,
    this.badgeText,
    this.floatingIcon,
    required this.title,
    this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Media Query bach n-3erfou l-7ajm dyal l-chacha
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isMobile ? 150 : 180, // N-n-9sou l-irtifa3 f l-mobile
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: gradient == null && imagePath == null ? buttonColor.withOpacity(0.05) : null,
                    gradient: gradient,
                    image: imagePath != null ? DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover) : null,
                  ),
                  child: Stack(
                    children: [
                      if (floatingIcon != null)
                        Center(child: Icon(floatingIcon, size: isMobile ? 60 : 80, color: Colors.white.withOpacity(0.2))),
                      if (badgeText != null)
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(badgeText!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 15 : 20), // N-n-9sou l-padding f l-mobile
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      Text(description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.grey[600], height: 1.4)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(buttonText, style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14)),
                          const SizedBox(width: 5),
                          Icon(Icons.arrow_forward, size: 14, color: buttonColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
