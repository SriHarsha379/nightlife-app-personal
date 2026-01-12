// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'app_color.dart';
// import 'app_config_provider.dart';

// class MediaViewerBottomSheet extends StatefulWidget {
//   final List<dynamic> mediaList;
//   final int initialIndex;

//   const MediaViewerBottomSheet({
//     super.key,
//     required this.mediaList,
//     required this.initialIndex,
//   });

//   @override
//   State<MediaViewerBottomSheet> createState() =>
//       _MediaViewerBottomSheetState();
// }

// class _MediaViewerBottomSheetState extends State<MediaViewerBottomSheet> {
//   late PageController _pageController;
//   late int _currentIndex;
//   VideoPlayerController? _videoController;
//   bool _isVideoInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//     _initializeMedia(_currentIndex);
//   }

//   void _initializeMedia(int index) {
//     var mediaItem = widget.mediaList[index];
//     int mediaType = mediaItem["media_type"] ?? 1;

//     if (mediaType == 2) {
//       String videoUrl = mediaItem["workshop_media"] ?? "";
//       _initializeVideo("${AppConfigProvider.imageUrl}$videoUrl");
//     } else {
//       _disposeVideo(updateState: true);
//     }
//   }

//   Future<void> _initializeVideo(String url) async {
//     try {
//       _disposeVideo(updateState: false);

//       _videoController = VideoPlayerController.network(url);
//       await _videoController!.initialize();

//       if (!mounted) return;

//       setState(() => _isVideoInitialized = true);

//       _videoController!.play();
//       _videoController!.addListener(() {
//         if (mounted) setState(() {});
//       });
//     } catch (e) {
//       log("Video init error: $e");
//       setState(() => _isVideoInitialized = false);
//     }
//   }

//   void _disposeVideo({bool updateState = true}) {
//     _videoController?.pause();
//     _videoController?.dispose();
//     _videoController = null;
//     _isVideoInitialized = false;

//     if (updateState && mounted) setState(() {});
//   }

//   @override
//   void dispose() {
//     _disposeVideo(updateState: false);
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: IconButton(
//             icon: const Icon(Icons.close, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text(
//             "${_currentIndex + 1} / ${widget.mediaList.length}",
//             style: const TextStyle(color: Colors.white),
//           ),
//           centerTitle: true,
//         ),
//         body: PageView.builder(
//           controller: _pageController,
//           itemCount: widget.mediaList.length,
//           onPageChanged: (index) {
//             setState(() => _currentIndex = index);
//             _initializeMedia(index);
//           },
//           itemBuilder: (context, index) {
//             var mediaItem = widget.mediaList[index];
//             int mediaType = mediaItem["media_type"] ?? 1;
//             String mediaUrl = mediaItem["workshop_media"] ?? "";

//             if (mediaType == 2) {
//               return Center(
//                 child: _isVideoInitialized &&
//                         _currentIndex == index &&
//                         _videoController != null
//                     ? AspectRatio(
//                         aspectRatio:
//                             _videoController!.value.aspectRatio,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             VideoPlayer(_videoController!),
//                             GestureDetector(
//                               onTap: () {
//                                 _videoController!.value.isPlaying
//                                     ? _videoController!.pause()
//                                     : _videoController!.play();
//                               },
//                               child: Container(
//                                 color: Colors.transparent,
//                                 child: Center(
//                                   child: _videoController!
//                                           .value.isBuffering
//                                       ? const CircularProgressIndicator(
//                                           color: Colors.white,
//                                         )
//                                       : _videoController!
//                                               .value.isPlaying
//                                           ? const SizedBox()
//                                           : Container(
//                                               width: 80,
//                                               height: 80,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.black
//                                                     .withOpacity(0.7),
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.play_arrow,
//                                                 color: Colors.white,
//                                                 size: 60,
//                                               ),
//                                             ),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: VideoProgressIndicator(
//                                 _videoController!,
//                                 allowScrubbing: true,
//                                 colors: const VideoProgressColors(
//                                   playedColor:
//                                       AppColor.textcolor,
//                                   bufferedColor: Colors.grey,
//                                   backgroundColor: Colors.white24,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : const CircularProgressIndicator(
//                         color: Colors.white,
//                       ),
//               );
//             }

//             return InteractiveViewer(
//               minScale: 1,
//               maxScale: 4,
//               child: Center(
//                 child: Image.network(
//                   "${AppConfigProvider.imageUrl}$mediaUrl",
//                   fit: BoxFit.contain,
//                   loadingBuilder: (_, child, progress) =>
//                       progress == null
//                           ? child
//                           : const CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                   errorBuilder: (_, __, ___) => const Icon(
//                     Icons.broken_image,
//                     color: Colors.white,
//                     size: 80,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'app_color.dart';

class MediaViewerBottomSheet extends StatefulWidget {
  final List<dynamic> mediaList;
  final int initialIndex;

  const MediaViewerBottomSheet({
    super.key,
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<MediaViewerBottomSheet> createState() => _MediaViewerBottomSheetState();
}

class _MediaViewerBottomSheetState extends State<MediaViewerBottomSheet> {
  late PageController _pageController;
  late ScrollController _thumbController;
  late int _currentIndex;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _thumbController = ScrollController();
    _initializeMedia(_currentIndex);
  }

  void _initializeMedia(int index) {
    final mediaItem = widget.mediaList[index];
    final int mediaType = mediaItem['media_type'] ?? 1;
    final String mediaPath = mediaItem['workshop_media'] ?? "";

    if (mediaType == 2) {
      _initializeVideo(mediaPath);
    } else {
      _disposeVideo(updateState: true);
    }

    _scrollToThumbnail(index);
  }

  Future<void> _initializeVideo(String assetPath) async {
    try {
      _disposeVideo(updateState: false);

      _videoController = VideoPlayerController.asset(assetPath);
      await _videoController!.initialize();

      if (!mounted) return;

      setState(() => _isVideoInitialized = true);
      _videoController!.play();

      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      log("Video init error: $e");
      if (mounted) {
        setState(() => _isVideoInitialized = false);
      }
    }
  }

  void _disposeVideo({bool updateState = true}) {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;

    if (updateState && mounted) setState(() {});
  }

  void _scrollToThumbnail(int index) {
    const double itemWidth = 72;
    _thumbController.animateTo(
      index * itemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _disposeVideo(updateState: false);
    _pageController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.2),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.2),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "${_currentIndex + 1} / ${widget.mediaList.length}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            /// ================= MAIN VIEW =================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaList.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _initializeMedia(index);
                },
                itemBuilder: (context, index) {
                  final mediaItem = widget.mediaList[index];
                  final int mediaType = mediaItem['media_type'] ?? 1;
                  final String mediaPath = mediaItem['workshop_media'] ?? "";

                  if (mediaType == 2) {
                    return Center(
                      child: _isVideoInitialized &&
                              _currentIndex == index &&
                              _videoController != null
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(_videoController!),
                                  GestureDetector(
                                    onTap: () {
                                      _videoController!.value.isPlaying
                                          ? _videoController!.pause()
                                          : _videoController!.play();
                                      setState(() {});
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: _videoController!
                                                .value.isBuffering
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : _videoController!.value.isPlaying
                                                ? const SizedBox()
                                                : Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.7),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 60,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: VideoProgressIndicator(
                                      _videoController!,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: AppColor.textcolor,
                                        bufferedColor: Colors.grey,
                                        backgroundColor: Colors.white24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                    );
                  }

                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 40 / 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            mediaPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ================= PREVIEW LIST =================
            Container(
              alignment: Alignment.center,
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                controller: _thumbController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.mediaList.length,
                itemBuilder: (context, index) {
                  final mediaItem = widget.mediaList[index];
                  final int mediaType = mediaItem['media_type'] ?? 1;
                  final String mediaPath = mediaItem['workshop_media'] ?? "";

                  final bool isActive = index == _currentIndex;

                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isActive ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: mediaType == 2
                                ? Image.asset(
                                    'assets/images/video_placeholder.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.asset(
                                    mediaPath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          if (mediaType == 2)
                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 2 / 100,
            ),
          ],
        ),
      ),
    );
  }
}
