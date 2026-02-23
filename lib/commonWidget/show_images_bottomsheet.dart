import 'package:flutter/material.dart';
import '../utilities/app_color.dart';
import '../utilities/app_image.dart';
import '../utilities/app_config_provider.dart';

class GalleryBottomSheet {
  static void show(
    BuildContext context, {
    required List<String> galleryImages,
    int initialIndex = 0,
  }) {
    final size = MediaQuery.of(context).size;

    PageController pageController = PageController(initialPage: initialIndex);
    int currentPage = initialIndex;

    // Convert image paths to full URLs
    List<String> processedImages = galleryImages.map((imagePath) {
      if (imagePath.isEmpty) return '';
      if (imagePath.startsWith('http')) return imagePath;
      return '${AppConfigProvider.imageUrl}$imagePath';
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: size.height * 0.8,
              decoration: BoxDecoration(
                color: AppColor.transparentColor.withOpacity(.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  /// -------- CLOSE BUTTON --------
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: size.height * 2 / 100),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColor.secondryColor(context),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- MAIN IMAGE WITH ARROWS --------
                  Container(
                    height: size.height * 0.35,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: processedImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 3 / 100),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _buildImageWidget(
                                  processedImages[index],
                                  context,
                                ),
                              ),
                            );
                          },
                        ),

                        /// -------- LEFT ARROW --------
                        if (currentPage > 0)
                          Positioned(
                            left: size.width * 5 / 100,
                            top: size.height * 0.15,
                            child: GestureDetector(
                              onTap: () {
                                pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                        /// -------- RIGHT ARROW --------
                        if (currentPage < processedImages.length - 1)
                          Positioned(
                            right: size.width * 5 / 100,
                            top: size.height * 0.15,
                            child: GestureDetector(
                              onTap: () {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- GALLERY GRID --------
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 5 / 100),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: processedImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = index;
                              });
                              pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: currentPage == index
                                      ? AppColor.pinkColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: _buildImageWidget(
                                  processedImages[index],
                                  context,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build image widget with network/asset fallback
  static Widget _buildImageWidget(String imageUrl, BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        AppImage.dummyImageIcon,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppImage.dummyImageIcon,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.buttonColor,
            ),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          AppImage.dummyImageIcon,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
