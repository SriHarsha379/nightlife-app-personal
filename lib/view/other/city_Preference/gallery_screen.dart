import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/media_picker_helper.dart';
import 'vibeCheckScreens/vibe_check_screens.dart';

class GalleryScreen extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;
  final String? selectedEvents;
  final String? customEvent;
  final String? selectedVibes;
  final String? sexuality;
  final String? interestedIn;
  final String? pronouns;
  static String routeName = './GalleryScreen';

  const GalleryScreen(
      {super.key,
      this.selectedGenres,
      this.customGenre,
      this.selectedEvents,
      this.customEvent,
      this.selectedVibes,
      this.sexuality,
      this.interestedIn,
      this.pronouns});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, String>> selectedMediaList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    log("data${widget.sexuality}");
    log("data${widget.interestedIn}");
    log("data${widget.pronouns}");
  }

  // Open media picker
  void _openMediaPicker() {
    if (selectedMediaList.length >= MediaPickerHelper.maxMediaItems) {
      SnackBarToastMessage.error(context,
          "Maximum ${MediaPickerHelper.maxMediaItems} items can be selected");
      return;
    }

    MediaPickerHelper.showMediaPickerBottomSheet(
      context,
      currentMediaCount: selectedMediaList.length,
      selectOptionText: AppLanguage.selectoptionText[language],
      galleryText: AppLanguage.gallerySelectText[language],
      cameraText: AppLanguage.cameraSelectText[language],
      videoText: AppLanguage.videoSelectText[language],
      cancelText: AppLanguage.cancelText[language],
      onImageFromCamera: (imageData) {
        setState(() {
          selectedMediaList.add(imageData);
        });
      },
      onVideoFromCamera: (videoData) {
        setState(() {
          selectedMediaList.add(videoData);
        });
      },
      onMediaFromGallery: (mediaList) {
        setState(() {
          int remainingSlots =
              MediaPickerHelper.maxMediaItems - selectedMediaList.length;
          int itemsToAdd = mediaList.length > remainingSlots
              ? remainingSlots
              : mediaList.length;
          selectedMediaList.addAll(mediaList.take(itemsToAdd));

          if (mediaList.length > remainingSlots) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Only $itemsToAdd items added. Maximum ${MediaPickerHelper.maxMediaItems} items allowed."),
                backgroundColor: AppColor.pinkColor,
              ),
            );
          }
        });
      },
    );
  }

  // Remove media item
  void _removeMediaItem(int index) {
    setState(() {
      selectedMediaList.removeAt(index);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
                // Header
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 4 / 100,
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: Image.asset(
                                  AppImage.backArrowIcon,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.GalleryText[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                // Description
                SizedBox(
                  width: MediaQuery.of(context).size.width * 88 / 100,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.uploadPhotosstatementText[language],
                      style: TextStyle(
                        fontFamily: AppFont.plusJakartaSansFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                // Media Grid
                SizedBox(
                  width: size.width,
                  child: ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, rowIndex) {
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: size.height * 2.5 / 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (colIndex) {
                            int itemIndex = rowIndex * 3 + colIndex;

                            // Show selected media or empty box
                            if (itemIndex < selectedMediaList.length) {
                              // Show selected media
                              return _buildMediaItem(
                                size,
                                selectedMediaList[itemIndex],
                                itemIndex,
                              );
                            } else if (itemIndex == selectedMediaList.length &&
                                selectedMediaList.length <
                                    MediaPickerHelper.maxMediaItems) {
                              // Show add button
                              return _buildAddButton(size);
                            } else {
                              // Show empty box
                              return _buildEmptyBox(size);
                            }
                          }),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 10 / 100,
                ),
                // Continue Button
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () {
                      log("all image and video also thumbnail${selectedMediaList}");
                      if (selectedMediaList.isEmpty) {
                        SnackBarToastMessage.error(
                            context, "Please select at least 1 photo or video");
                        return;
                      }

                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: VibeCheckScreen(
                            selectedGenres: widget.selectedGenres,
                            customGenre: widget.customGenre,
                            selectedEvents: widget.selectedEvents,
                            customEvent: widget.customEvent,
                            selectedVibes: widget.selectedVibes,
                            sexuality: widget.sexuality,
                            interestedIn: widget.interestedIn,
                            pronouns: widget.pronouns,
                            selectedMediaList: selectedMediaList,
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build media item (image or video)
  Widget _buildMediaItem(Size size, Map<String, String> mediaData, int index) {
    bool isVideo = mediaData['type'] == 'video';
    String filePath = mediaData['file'] ?? '';
    String thumbnailPath = mediaData['thumbnail'] ?? '';

    return GestureDetector(
      onTap: () {
        // _showMediaOptions(index);
      },
      child: Stack(
        children: [
          Container(
            width: size.width * 26 / 100,
            height: size.width * 32 / 100,
            decoration: BoxDecoration(
              color: AppColor.transparentColor,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: AppColor.pinkColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: isVideo
                  ? (thumbnailPath.isNotEmpty &&
                          File(thumbnailPath).existsSync()
                      ? Image.file(
                          File(thumbnailPath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.black54,
                          child: const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 40,
                          ),
                        ))
                  : Image.file(
                      File(filePath),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          // Video play icon overlay
          if (isVideo)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: Colors.black26,
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          // Remove button
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                _removeMediaItem(index);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build add button
  Widget _buildAddButton(Size size) {
    return GestureDetector(
      onTap: _openMediaPicker,
      child: Container(
        width: size.width * 26 / 100,
        height: size.width * 32 / 100,
        decoration: BoxDecoration(
          color: AppColor.transparentColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: AppColor.pinkColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: size.width * 7 / 100,
            color: AppColor.secondryColor(context),
          ),
        ),
      ),
    );
  }

  // Build empty box
  Widget _buildEmptyBox(Size size) {
    return Container(
      width: size.width * 26 / 100,
      height: size.width * 32 / 100,
      decoration: BoxDecoration(
        color: AppColor.transparentColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColor.pinkColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Image.asset(
          AppImage.rectangleIcon,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // // Show media options
  // void _showMediaOptions(int index) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColor.themeColor,
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.delete, color: Colors.red),
  //               title: const Text('Remove'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _removeMediaItem(index);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.cancel),
  //               title: const Text('Cancel'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
