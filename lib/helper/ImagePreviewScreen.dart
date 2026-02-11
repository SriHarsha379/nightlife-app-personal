import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final List<Map<String, String>>? media;
  final int initialIndex;

  const ImagePreviewScreen({
    super.key,
    required this.images,
    this.media,
    this.initialIndex = 0,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late int currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initializeVideoIfNeeded(currentIndex);
  }

  void nextImage() {
    final itemsCount = widget.media != null && widget.media!.isNotEmpty
        ? widget.media!.length
        : widget.images.length;
    if (currentIndex < itemsCount - 1) {
      setState(() => currentIndex++);
      _initializeVideoIfNeeded(currentIndex);
    }
  }

  void previousImage() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _initializeVideoIfNeeded(currentIndex);
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  bool _isVideoAt(int index) {
    if (widget.media != null && widget.media!.isNotEmpty) {
      return (widget.media![index]['type'] ?? '') == 'video';
    }
    final path = widget.images[index].toLowerCase();
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm');
  }

  String _videoSourceAt(int index) {
    if (widget.media != null && widget.media!.isNotEmpty) {
      return widget.media![index]['source'] ??
          widget.media![index]['url'] ??
          '';
    }
    return widget.images[index];
  }

  String _displayPathAt(int index) {
    if (widget.media != null && widget.media!.isNotEmpty) {
      final item = widget.media![index];
      final type = item['type'] ?? 'image';
      if (type == 'video') {
        return item['thumbnail'] ?? item['url'] ?? '';
      }
      return item['url'] ?? '';
    }
    return widget.images[index];
  }

  Future<void> _initializeVideoIfNeeded(int index) async {
    if (!_isVideoAt(index)) {
      _disposeVideo();
      if (mounted) setState(() {});
      return;
    }

    final source = _videoSourceAt(index);
    if (source.isEmpty) {
      _disposeVideo();
      if (mounted) setState(() {});
      return;
    }

    _disposeVideo();

    try {
      if (source.startsWith('http://') || source.startsWith('https://')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(source));
      } else if (File(source).existsSync()) {
        _videoController = VideoPlayerController.file(File(source));
      } else {
        _videoController = VideoPlayerController.asset(source);
      }

      await _videoController!.initialize();
      if (!mounted) return;
      setState(() => _isVideoInitialized = true);
    } catch (_) {
      _disposeVideo();
      if (mounted) setState(() {});
    }
  }

  Widget _buildImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.white54);
        },
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemsCount = widget.media != null && widget.media!.isNotEmpty
        ? widget.media!.length
        : widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// ❌ CLOSE BUTTON
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /// MAIN IMAGE + ARROWS
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// LEFT ARROW
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: currentIndex > 0 ? previousImage : null,
                    ),

                    /// IMAGE (AUTO-FIT, NO OVERFLOW)
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          height: size.height * 0.60,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.95, end: 1.0)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: ClipRRect(
                              key: ValueKey(currentIndex),
                              borderRadius: BorderRadius.circular(26),
                              child: _isVideoAt(currentIndex)
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_isVideoInitialized &&
                                            _videoController != null)
                                          AspectRatio(
                                            aspectRatio: _videoController!
                                                .value.aspectRatio,
                                            child: VideoPlayer(
                                                _videoController!),
                                          )
                                        else
                                          _buildImage(
                                            _displayPathAt(currentIndex),
                                            fit: BoxFit.cover,
                                          ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_videoController == null) {
                                              return;
                                            }
                                            if (_videoController!
                                                .value.isPlaying) {
                                              _videoController!.pause();
                                            } else {
                                              _videoController!.play();
                                            }
                                            setState(() {});
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Center(
                                              child: (_videoController != null &&
                                                      _videoController!
                                                          .value.isPlaying)
                                                  ? const SizedBox()
                                                  : Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.6),
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
                                        const Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Icon(
                                            Icons.videocam,
                                            color: Colors.white70,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    )
                                  : _buildImage(
                                      _displayPathAt(currentIndex),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// RIGHT ARROW
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: currentIndex < itemsCount - 1 ? nextImage : null,
                    ),
                  ],
                ),
              ),
            ),

            /// THUMBNAILS
            SizedBox(
              height: size.height * 0.14,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: itemsCount,
                itemBuilder: (context, index) {
                  final isSelected = index == currentIndex;
                  final isVideo = _isVideoAt(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() => currentIndex = index);
                      _initializeVideoIfNeeded(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 12),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.purpleAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImage(
                              _displayPathAt(index),
                              fit: BoxFit.cover,
                            ),
                            if (isVideo)
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white70,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
