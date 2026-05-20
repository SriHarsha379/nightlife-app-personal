import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_font.dart';
import '../../utilities/media_picker_helper.dart';

class ReportProblemScreen extends StatefulWidget {
  static String routeName = './ReportProblemScreen';
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  static const int _maxReportMediaItems = 6;
  TextEditingController messageTextEditingController = TextEditingController();
  final List<Map<String, String>> selectedMediaList = [];

  @override
  void dispose() {
    messageTextEditingController.dispose();
    super.dispose();
  }

  void _openMediaPicker() {
    if (selectedMediaList.length >= _maxReportMediaItems) {
      SnackBarToastMessage.error(
          context, "Maximum $_maxReportMediaItems media files can be selected");
      return;
    }

    MediaPickerHelper.showMediaPickerBottomSheet(
      context,
      currentMediaCount: selectedMediaList.length,
      selectOptionText: "Select Option",
      galleryText: "Media from Gallery",
      cameraText: AppLanguage.cameraSelectText[language],
      videoText: AppLanguage.videoSelectText[language],
      cancelText: AppLanguage.cancelText[language],
      onImageFromCamera: (media) {
        if (!mounted) return;
        setState(() {
          if (selectedMediaList.length < _maxReportMediaItems) {
            selectedMediaList.add(media);
          }
        });
      },
      onVideoFromCamera: (media) {
        if (!mounted) return;
        setState(() {
          if (selectedMediaList.length < _maxReportMediaItems) {
            selectedMediaList.add(media);
          }
        });
      },
      onMediaFromGallery: (mediaFromGallery) {
        if (!mounted) return;
        setState(() {
          final remainingSlots =
              _maxReportMediaItems - selectedMediaList.length;
          final itemsToAdd = mediaFromGallery.length > remainingSlots
              ? remainingSlots
              : mediaFromGallery.length;
          selectedMediaList.addAll(mediaFromGallery.take(itemsToAdd));

          if (mediaFromGallery.length > remainingSlots) {
            SnackBarToastMessage.error(
              context,
              "Only $itemsToAdd items added. Maximum $_maxReportMediaItems media files allowed.",
            );
          }
        });
      },
    );
  }

  void _removeMediaItem(int index) {
    setState(() {
      selectedMediaList.removeAt(index);
    });
  }

  Future<void> _submitProblem() async {
    final description = messageTextEditingController.text.trim();
    if (description.isEmpty) {
      SnackBarToastMessage.info(context, "Please enter description");
      return;
    }
    if (selectedMediaList.length > _maxReportMediaItems) {
      SnackBarToastMessage.error(
          context, "Maximum $_maxReportMediaItems media files allowed");
      return;
    }

    final List<XFile> images = [];
    final List<XFile> videos = [];
    final List<XFile> thumbnails = [];

    for (final media in selectedMediaList) {
      final type = (media['type'] ?? '').toLowerCase();
      final filePath = media['file'] ?? '';
      final thumbPath = media['thumbnail'] ?? '';

      if (filePath.isEmpty) continue;

      if (type == 'image') {
        images.add(XFile(filePath));
      } else if (type == 'video') {
        videos.add(XFile(filePath));
        if (thumbPath.isNotEmpty) {
          thumbnails.add(XFile(thumbPath));
        }
      }
    }

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.reportProblemApi(
      context,
      description: description,
      images: images,
      videos: videos,
      thumbnails: thumbnails,
    );

    if (!mounted) return;
    if (res != null && res['success'] == true) {
      Navigator.pop(context);
    }
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
        backgroundColor: AppColor.primaryColor(context),
        body: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor(context),
          child: Column(
            children: [
              SizedBox(height: size.height * 5 / 100),
              AppHeader(
                text: AppLanguage.reportAproblemText[language],
                onPress: () => Navigator.pop(context),
              ),
              SizedBox(height: size.height * 2 / 100),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 5 / 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Description Heading
                      Container(
                        width: size.width * 90 / 100,
                        child: Text(
                          AppLanguage.descriptionText[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      /// Description Field
                      Container(
                        padding: EdgeInsets.symmetric(),
                        decoration: BoxDecoration(
                            color: const Color(0xff36214A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.appButtonColor)),
                        child: TextField(
                          controller: messageTextEditingController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFont.fontFamily,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                AppLanguage.describeYourIssueText[language],
                            hintStyle: TextStyle(
                                color: AppColor.filledText(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 3 / 100),

                      /// Add Screenshots
                      Text(
                        AppLanguage.addScreenshotsText[language],
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 17,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: size.height * 0.1 / 100),

                      Text(
                        'Add screenshots or videos to help us understand the issue better.',
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 12,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: size.height * 1.5 / 100),

                      Wrap(
                        spacing: size.width * 3 / 100,
                        runSpacing: size.height * 1.6 / 100,
                        children: List.generate(
                          selectedMediaList.length < _maxReportMediaItems
                              ? selectedMediaList.length + 1
                              : selectedMediaList.length,
                          (index) {
                            if (index < selectedMediaList.length) {
                              return _buildMediaItem(
                                size,
                                selectedMediaList[index],
                                index,
                              );
                            }
                            return _uploadBox(size, isAdd: true);
                          },
                        ),
                      ),

                      SizedBox(height: size.height * 1 / 100),
                      Text(
                        "${selectedMediaList.length}/$_maxReportMediaItems media selected",
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 12,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                      Text(
                        "Tip: videos take longer to upload. Short clips work best.",
                        style: TextStyle(
                          color: AppColor.spancolor(context),
                          fontSize: 11,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                      SizedBox(height: size.height * 15 / 100),

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: AppFont.fontFamily,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "By submitting, you allow ",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              ),
                              TextSpan(
                                text: "Hii App",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
                              ),
                              TextSpan(
                                text:
                                    " to preview related technical info to help address your feedback",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 3 / 100),

                      Center(
                        child: Consumer<PostApiProvider>(
                          builder: (context, apiprovider, child) {
                            if (apiprovider.loading) {
                              return const CircularProgressIndicator(
                                color: AppColor.pinkColor,
                              );
                            }
                            return GestureDetector(
                              onTap: _submitProblem,
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    80 /
                                    100,
                                height: MediaQuery.of(context).size.height *
                                    7 /
                                    100,
                                decoration: const BoxDecoration(
                                  color: AppColor.buttonColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  AppLanguage.submitText[language],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Center(
                      //   child: GestureDetector(
                      //     onTap: isLoading ? null : _submitProblem,
                      //     child: Container(
                      //       width: MediaQuery.of(context).size.width * 80 / 100,
                      //       height:
                      //           MediaQuery.of(context).size.height * 7 / 100,
                      //       decoration: const BoxDecoration(
                      //         color: AppColor.buttonColor,
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(40)),
                      //       ),
                      //       alignment: Alignment.center,
                      //       child: isLoading
                      //           ? const SizedBox(
                      //               width: 22,
                      //               height: 22,
                      //               child: CircularProgressIndicator(
                      //                 strokeWidth: 2.4,
                      //                 color: Colors.white,
                      //               ),
                      //             )
                      //           : Text(
                      //               AppLanguage.submitText[language],
                      //               style: const TextStyle(
                      //                   color: Colors.white,
                      //                   fontWeight: FontWeight.w600,
                      //                   fontFamily: AppFont.fontFamily,
                      //                   fontSize: 16),
                      //             ),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(height: size.height * 4 / 100),

                      /// Footer Text
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(Size size, Map<String, String> mediaData, int index) {
    final isVideo = mediaData['type'] == 'video';
    final filePath = mediaData['file'] ?? '';
    final thumbnailPath = mediaData['thumbnail'] ?? '';

    return Stack(
      children: [
        Container(
          width: size.width * 26 / 100,
          height: size.width * 32 / 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColor.buttonColor,
              width: .7,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isVideo
                ? (thumbnailPath.isNotEmpty && File(thumbnailPath).existsSync()
                    ? Image.file(File(thumbnailPath), fit: BoxFit.fill)
                    : Container(
                        color: Colors.black45,
                        child: const Icon(Icons.videocam, color: Colors.white),
                      ))
                : (filePath.isNotEmpty && File(filePath).existsSync()
                    ? Image.file(File(filePath), fit: BoxFit.fill)
                    : Container(
                        color: Colors.black45,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                        ),
                      )),
          ),
        ),
        if (isVideo)
          const Positioned.fill(
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMediaItem(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadBox(Size size, {bool isAdd = false}) {
    return GestureDetector(
      onTap: _openMediaPicker,
      child: Container(
        height: size.width * 32 / 100,
        width: size.width * 26 / 100,
        decoration: BoxDecoration(
          color: AppColor.transparentColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: AppColor.pinkColor,
            width: 1,
          ),
        ),
        child: isAdd
            ? Center(
                child: Icon(
                  Icons.add,
                  size: size.width * 7 / 100,
                  color: AppColor.secondryColor(context),
                ),
              )
            : null,
      ),
    );
  }
}
