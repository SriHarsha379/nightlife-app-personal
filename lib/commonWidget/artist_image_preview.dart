import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utilities/app_color.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_image.dart';

class LineupArtistPreviewScreen extends StatelessWidget {
  final String imagePath;

  const LineupArtistPreviewScreen({
    super.key,
    required this.imagePath,
  });

  String _resolvedImageUrl() {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return "${AppConfigProvider.imageUrl}$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 2 / 100,
                    vertical: size.height * 2 / 100,
                  ),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: SizedBox(
                      width: size.width * 0.96,
                      height: size.height * 0.78,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: CachedNetworkImage(
                          imageUrl: _resolvedImageUrl(),
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => Image.asset(
                            AppImage.placeHolderIcon,
                            fit: BoxFit.contain,
                          ),
                          placeholder: (context, url) => Center(
                            child: LoadingAnimationWidget.dotsTriangle(
                              color: AppColor.themeColor,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
