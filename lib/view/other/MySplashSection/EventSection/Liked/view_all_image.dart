import 'package:flutter/material.dart';

import '../../../../../utilities/app_image.dart';

class GalleryView extends StatefulWidget {
  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  int currentIndex = 0;

  final List<String> galleryImages = [
    AppImage.eventimg,
    AppImage.eventimg,
    AppImage.eventimg,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// -------- IMAGE SLIDER --------
          PageView.builder(
            itemCount: galleryImages.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  galleryImages[index],
                  fit: BoxFit.contain,
                  width: size.width,
                ),
              );
            },
          ),

          /// -------- CLOSE BUTTON --------
          Positioned(
            top: size.height * 6 / 100,
            right: size.width * 6 / 100,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          /// -------- IMAGE COUNT --------
          Positioned(
            bottom: size.height * 6 / 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "${currentIndex + 1} / ${galleryImages.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
