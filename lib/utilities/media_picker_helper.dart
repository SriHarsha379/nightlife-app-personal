import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class MediaPickerHelper {
  static const int maxMediaItems = 9;
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB

  // Check file size
  static Future<bool> checkFileSize(BuildContext context, String filePath,
      {Function(String)? onError}) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();

      if (fileSize > maxFileSizeInBytes) {
        final fileSizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        final limitInMB =
            (maxFileSizeInBytes / (1024 * 1024)).toStringAsFixed(0);
        final errorMsg =
            "File size ($fileSizeInMB MB) exceeds $limitInMB MB limit";
        if (onError != null) {
          onError(errorMsg);
        }
        return false;
      }
      return true;
    } catch (e) {
      print("Error checking file size: $e");
      return false;
    }
  }

  // Generate video thumbnail
  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print("Error generating thumbnail: $e");
      return null;
    }
  }

  // Pick image from camera
  static Future<Map<String, String>?> pickImageFromCamera(BuildContext context,
      {Function(String)? onError}) async {
    try {
      XFile? media = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (media == null) {
        print("No image captured.");
        return null;
      }

      // Check file size
      if (!await checkFileSize(context, media.path, onError: onError)) {
        return null;
      }

      return {
        'type': 'image',
        'file': media.path,
        'thumbnail': '',
      };
    } catch (e) {
      print("Error capturing image: $e");
      if (onError != null) {
        onError("Error capturing image");
      }
      return null;
    }
  }

  // Pick video from camera or gallery
  static Future<Map<String, String>?> pickVideo(
      BuildContext context, ImageSource source,
      {Function(String)? onError}) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 30),
      );

      if (pickedFile != null) {
        String videoFilePath = pickedFile.path;

        // Verify video file exists
        if (!File(videoFilePath).existsSync()) {
          print("Video file does not exist at path: $videoFilePath");
          return null;
        }

        // Check file size
        if (!await checkFileSize(context, videoFilePath, onError: onError)) {
          return null;
        }

        print("Video file path: $videoFilePath");

        // Generate thumbnail
        String? thumbnailPath = await generateThumbnail(videoFilePath);

        return {
          'type': 'video',
          'file': videoFilePath,
          'thumbnail': thumbnailPath ?? '',
        };
      } else {
        print("No video selected.");
        return null;
      }
    } catch (e) {
      print("Error picking video: $e");
      if (onError != null) {
        onError("Error picking video");
      }
      return null;
    }
  }

  // Pick multiple media from gallery
  static Future<List<Map<String, String>>> pickMultipleMediaFromGallery(
      BuildContext context, int currentMediaCount,
      {Function(String)? onError}) async {
    try {
      List<XFile>? media = await ImagePicker().pickMultipleMedia();

      if (media == null || media.isEmpty) {
        print("No media selected.");
        return [];
      }

      List<Map<String, String>> updatedMediaList = [];
      int remainingSlots = maxMediaItems - currentMediaCount;
      bool fileTooLarge = false;

      // Process only the first few files that fit within the limit
      for (int i = 0;
          i < media.length && updatedMediaList.length < remainingSlots;
          i++) {
        var file = media[i];
        String filePath = file.path;

        // Verify file exists
        if (!File(filePath).existsSync()) {
          print("File does not exist: $filePath");
          continue;
        }

        // Check file size
        final fileSize = await File(filePath).length();
        if (fileSize > maxFileSizeInBytes) {
          final fileSizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
          print("File too large: $fileSizeInMB MB");
          fileTooLarge = true;
          continue;
        }

        String? mimeType = lookupMimeType(filePath);

        if (mimeType == null) {
          print("Could not determine MIME type for: $filePath");
          continue;
        }

        if (mimeType.startsWith('image/')) {
          updatedMediaList.add({
            'type': 'image',
            'file': filePath,
            'thumbnail': '',
          });
        } else if (mimeType.startsWith('video/')) {
          String? thumbnailPath = await generateThumbnail(filePath);

          updatedMediaList.add({
            'type': 'video',
            'file': filePath,
            'thumbnail': thumbnailPath ?? '',
          });
        }
      }

      if (fileTooLarge && onError != null) {
        final limitInMB =
            (maxFileSizeInBytes / (1024 * 1024)).toStringAsFixed(0);
        onError("Some files exceeded $limitInMB MB limit and were skipped");
      }

      print(
          "Added ${updatedMediaList.length} media items out of ${media.length} selected");
      return updatedMediaList;
    } catch (e) {
      print("Error selecting media from gallery: $e");
      if (onError != null) {
        onError("Error selecting media from gallery");
      }
      return [];
    }
  }

  // Show media picker bottom sheet
  static void showMediaPickerBottomSheet(
    BuildContext context, {
    required Function(Map<String, String>) onImageFromCamera,
    required Function(Map<String, String>) onVideoFromCamera,
    required Function(List<Map<String, String>>) onMediaFromGallery,
    required int currentMediaCount,
    String? selectOptionText,
    String? galleryText,
    String? cameraText,
    String? videoText,
    String? cancelText,
  }) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xff00000030),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: ((context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 37 / 100,
            width: MediaQuery.of(context).size.width * 80 / 100,
            color: const Color(0xff00000030),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  Container(
                    width: MediaQuery.of(context).size.width * 80 / 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),
                        Text(
                          selectOptionText ?? "Select Option",
                          style: TextStyle(
                              color: Color.fromARGB(255, 32, 32, 32),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Container(
                            height:
                                MediaQuery.of(context).size.height * 0.1 / 100,
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            color: const Color(0xffd7d7d7)),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        // Gallery Option
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            if (currentMediaCount >= maxMediaItems) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Maximum 9 items already selected")),
                              );
                              return;
                            }
                            List<Map<String, String>> mediaList =
                                await pickMultipleMediaFromGallery(
                                    context, currentMediaCount,
                                    onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            });
                            if (mediaList.isNotEmpty) {
                              onMediaFromGallery(mediaList);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Text(
                              galleryText ?? "Gallery",
                              style: const TextStyle(
                                  color: Color(0xff323232),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Container(
                            height:
                                MediaQuery.of(context).size.height * 0.1 / 100,
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            color: const Color(0xffd7d7d7)),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        // Camera Option
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            if (currentMediaCount >= maxMediaItems) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Maximum 9 items already selected")),
                              );
                              return;
                            }
                            Map<String, String>? imageData =
                                await pickImageFromCamera(context,
                                    onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            });
                            if (imageData != null) {
                              onImageFromCamera(imageData);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Text(
                              cameraText ?? "Camera",
                              style: const TextStyle(
                                  color: Color(0xff323232),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Container(
                            height:
                                MediaQuery.of(context).size.height * 0.1 / 100,
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            color: const Color(0xffd7d7d7)),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        // Video Option
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            if (currentMediaCount >= maxMediaItems) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Maximum 9 items already selected")),
                              );
                              return;
                            }
                            Map<String, String>? videoData = await pickVideo(
                                context, ImageSource.camera, onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            });
                            if (videoData != null) {
                              onVideoFromCamera(videoData);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Text(
                              videoText ?? "Video",
                              style: const TextStyle(
                                  color: Color(0xff323232),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 7 / 100,
                      width: MediaQuery.of(context).size.width * 80 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cancelText ?? "Cancel",
                        style: const TextStyle(
                            color: Color(0xffff5050),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100),
                ],
              ),
            ),
          );
        }));
      },
    );
  }
}
