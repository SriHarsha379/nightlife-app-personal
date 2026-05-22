import 'package:flutter/material.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:night_life/utilities/url_utils.dart';
import '../utilities/app_color.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../view/other/MySplashSection/MembersSection/member_liked_details.dart';

class HomeWidget {
  int selectedIndex = 0;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatLikes(int count) {
    if (count >= 1000) {
      final double val = count / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}K';
    }
    return count.toString();
  }

  static Widget _buildLikesOverlay(
    BuildContext context, {
    List<String>? recentUserImages,
    int? recentCount,
    int? totalLikes,
  }) {
    final List<String> safeImages = (recentUserImages ?? const <String>[])
        .where((image) => image.trim().isNotEmpty)
        .take(2)
        .toList();
    final int safeRecentCount = _toInt(recentCount);
    final int safeTotalLikes = _toInt(totalLikes);
    final bool hasBubble = safeRecentCount > 0;

    if (safeImages.isEmpty && !hasBubble && safeTotalLikes <= 0) {
      return const SizedBox.shrink();
    }

    const double avatarSize = 40;
    const double overlapOffset = 26;

    final int totalItems = safeImages.length + (hasBubble ? 1 : 0);
    final double totalWidth = totalItems == 0
        ? avatarSize
        : avatarSize + ((totalItems - 1) * overlapOffset);

    return Positioned(
      top: 6,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: totalWidth,
            height: avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int index = 0; index < safeImages.length; index++)
                  Positioned(
                    left: index * overlapOffset,
                    child: _buildLikeAvatar(
                      image: safeImages[index],
                      size: avatarSize,
                    ),
                  ),
                if (hasBubble)
                  Positioned(
                    left: safeImages.length * overlapOffset,
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.borderColor,
                        border: Border.all(
                          color: const Color(0xFF9C27B0),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$safeRecentCount',
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
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatLikes(safeTotalLikes)} Likes',
            style: TextStyle(
              color: AppColor.spancolor(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLikeAvatar({
    required String image,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF9C27B0), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: isNetworkUrl(image)
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    AppImage.placeHolder2Icon,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                AppImage.placeHolder2Icon,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget _cardImageLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.pinkAccent,
          ),
        ),
      ),
    );
  }

  static Widget _adImage({
    required String image,
  }) {
    if (isNetworkUrl(image)) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _cardImageLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppImage.dummyImageIcon,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      image.isNotEmpty ? image : AppImage.dummyImageIcon,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          AppImage.dummyImageIcon,
          fit: BoxFit.cover,
        );
      },
    );
  }

  static Widget adCard(
    BuildContext context,
    String image, {
    Key? key,
    required double progress,
    required int secondsRemaining,
  }) {
    final size = MediaQuery.of(context).size;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      key: key,
      width: size.width * 85 / 100,
      height: size.height * 57.5 / 100,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.16),
                  blurRadius: 1,
                  spreadRadius: 1.5,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _adImage(image: image),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.08),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F2A8B).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 5,
                      color: Colors.white.withOpacity(0.35),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: clampedProgress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFF3BC1),
                                  Color(0xFF28A7FF),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${secondsRemaining.clamp(0, 5)} Sec',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDecisionBadge(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
    String? semanticsLabel,
  }) {
    final size = MediaQuery.of(context).size;
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: isActive ? 0.92 : 1.0,
            end: isActive ? 1.0 : 0.96,
          ),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: isActive ? 1.0 : 0.8,
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.032,
              vertical: size.height * 0.009,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.96)
                  : Colors.black.withOpacity(0.48),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isActive ? color : Colors.white.withOpacity(0.28),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isActive ? 0.42 : 0.18),
                  blurRadius: isActive ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: size.width * 0.043,
                ),
                SizedBox(width: size.width * 0.015),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.031,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.fontFamily,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build members card
  static Widget membersCard(
    BuildContext context,
    String image,
    String name,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onRejectTap,
    required Function() onMessageTap,
    required Function() onHeartTap,
    String? bio,
    List<String>? vibes,
    String? distance,
    String? memberId,
    Function(dynamic)? onDetailResult,
  }) {
    final String safeBio = (bio ?? '').trim();
    final List<String> safeVibes =
        (vibes ?? const <String>[]).where((e) => e.trim().isNotEmpty).toList();
    final bool hasBio = safeBio.isNotEmpty;
    final bool hasVibes = safeVibes.isNotEmpty;
    final bool showAcceptFeedback =
        (showHeart || showCross) && lastSwipeType == 'accept';
    final bool showRejectFeedback =
        (showHeart || showCross) && lastSwipeType == 'reject';
    final double badgeTop = MediaQuery.of(context).size.height * 0.018;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        onVerticalDragEnd: (details) async {
          final velocity = details.primaryVelocity ?? 0;

          if (velocity < -300) {
            final result = await Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: LikedMemberDetail(memberId: memberId),
                duration: const Duration(milliseconds: 400),
              ),
            );
            if (onDetailResult != null) {
              onDetailResult(result);
            }
          }
        },
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 1,
                      spreadRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            // Image Container with proper constraints
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: isNetworkUrl(image)
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return _cardImageLoadingPlaceholder();
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          AppImage.placeHolder2Icon,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      image, // Changed from AppImage.placeHolder2Icon to use actual image parameter
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          AppImage.placeHolder2Icon,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      },
                                    ),
                            ),
                            // Shadow overlay that blends into the info section
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: hasBio
                                    ? MediaQuery.of(context).size.height *
                                        .5 /
                                        100
                                    : 0,
                              ),
                              Text(
                                hasBio ? safeBio : '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: (hasBio && hasVibes)
                                    ? MediaQuery.of(context).size.height *
                                        .5 /
                                        100
                                    : 0,
                              ),
                              Text(
                                hasVibes ? safeVibes.join(' • ') : "",
                                style: const TextStyle(
                                  color: AppColor.pinkColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      distance ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showRejectFeedback ? 'NO' : 'Reject',
                  icon: Icons.close_rounded,
                  color: AppColor.redColor,
                  isActive: showRejectFeedback,
                  onTap: onRejectTap,
                  semanticsLabel: 'Reject member',
                ),
              ),
              Positioned(
                right: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showAcceptFeedback ? 'YES' : 'Accept',
                  icon: Icons.favorite_rounded,
                  color: AppColor.greenColor,
                  isActive: showAcceptFeedback,
                  onTap: onHeartTap,
                  semanticsLabel: 'Accept member',
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onMessageTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build events card
  static Widget eventsCard(
    BuildContext context,
    String image,
    String name,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onRejectTap,
    required Function() onShareTap,
    required Function() onHeartTap,
    String? about,
    List<String>? categories,
    String? date,
    String? venueName,
    String? address,
    String? distance,
    List<String>? recentUserImages,
    int? recentCount,
    int? totalLikes,
  }) {
    final bool showAcceptFeedback =
        (showHeart || showCross) && lastSwipeType == 'accept';
    final bool showRejectFeedback =
        (showHeart || showCross) && lastSwipeType == 'reject';
    final double badgeTop = MediaQuery.of(context).size.height * 0.06;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 1,
                      spreadRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: isNetworkUrl(image)
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          AppImage.dummyImageIcon,
                                          fit: BoxFit.fitHeight,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      image,
                                      fit: BoxFit.fitHeight,
                                    ),
                            ),
                            // Shadow overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Text(
                                about ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      date ?? '',
                                      style: const TextStyle(
                                        color: AppColor.pinkColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${venueName ?? ''}, ${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //! Categories on Left Side
              if (categories != null && categories.isNotEmpty)
                Positioned(
                  top: 2,
                  left: -5,
                  child: SizedBox(
                    height: 41,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 5 / 100,
                          ),
                          ...categories.take(2).map((category) => Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColor.themeColor.withOpacity(.7),
                                    border: Border.all(
                                      color: const Color(0xFF9C27B0),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.7),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 10),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

              _buildLikesOverlay(
                context,
                recentUserImages: recentUserImages,
                recentCount: recentCount,
                totalLikes: totalLikes,
              ),

              Positioned(
                left: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showRejectFeedback ? 'NO' : 'Reject',
                  icon: Icons.close_rounded,
                  color: AppColor.redColor,
                  isActive: showRejectFeedback,
                  onTap: onRejectTap,
                  semanticsLabel: 'Reject event',
                ),
              ),

              Positioned(
                right: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showAcceptFeedback ? 'YES' : 'Accept',
                  icon: Icons.favorite_rounded,
                  color: AppColor.greenColor,
                  isActive: showAcceptFeedback,
                  onTap: onHeartTap,
                  semanticsLabel: 'Accept event',
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onShareTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Method to build venues card
  static Widget venuesCard(
    BuildContext context,
    String image,
    String name,
    String venueId,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onRejectTap,
    required Function() onShareTap,
    required Function() onHeartTap,
    String? about,
    List<String>? categories,
    String? timing,
    String? address,
    String? distance,
    List<String>? recentUserImages,
    int? recentCount,
    int? totalLikes,
  }) {
    final bool showAcceptFeedback =
        (showHeart || showCross) && lastSwipeType == 'accept';
    final bool showRejectFeedback =
        (showHeart || showCross) && lastSwipeType == 'reject';
    final double badgeTop = MediaQuery.of(context).size.height * 0.06;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 1,
                      spreadRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: isNetworkUrl(image)
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          AppImage.dummyImageIcon,
                                          fit: BoxFit.fitHeight,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      image,
                                      fit: BoxFit.fitHeight,
                                    ),
                            ),
                            // Shadow overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Text(
                                about ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      timing ?? '',
                                      style: const TextStyle(
                                        color: AppColor.pinkColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //! Categories on Left Side
              if (categories != null && categories.isNotEmpty)
                Positioned(
                  top: 2,
                  left: -5,
                  child: SizedBox(
                    height: 41,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 5 / 100,
                          ),
                          ...categories.take(2).map((category) => Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColor.themeColor.withOpacity(.7),
                                    border: Border.all(
                                        color: const Color(0xFF9C27B0),
                                        width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.7),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 10),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

              _buildLikesOverlay(
                context,
                recentUserImages: recentUserImages,
                recentCount: recentCount,
                totalLikes: totalLikes,
              ),

              Positioned(
                left: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showRejectFeedback ? 'NO' : 'Reject',
                  icon: Icons.close_rounded,
                  color: AppColor.redColor,
                  isActive: showRejectFeedback,
                  onTap: onRejectTap,
                  semanticsLabel: 'Reject venue',
                ),
              ),

              Positioned(
                right: 18,
                top: badgeTop,
                child: _buildDecisionBadge(
                  context,
                  label: showAcceptFeedback ? 'YES' : 'Accept',
                  icon: Icons.favorite_rounded,
                  color: AppColor.greenColor,
                  isActive: showAcceptFeedback,
                  onTap: onHeartTap,
                  semanticsLabel: 'Accept venue',
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onShareTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}



//===============================================//////////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:night_life/utilities/page_transition.dart';
// import '../utilities/app_color.dart';
// import '../utilities/app_font.dart';
// import '../utilities/app_image.dart';
// import '../view/other/MySplashSection/MembersSection/member_liked_details.dart';

// class HomeWidget {
//   int selectedIndex = 0;

//   static int _toInt(dynamic value) {
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     return int.tryParse(value?.toString() ?? '') ?? 0;
//   }

//   static String _formatLikes(int count) {
//     if (count >= 1000) {
//       final double val = count / 1000;
//       return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}K';
//     }
//     return count.toString();
//   }

//   static Widget _buildLikesOverlay(
//     BuildContext context, {
//     List<String>? recentUserImages,
//     int? recentCount,
//     int? totalLikes,
//   }) {
//     final List<String> safeImages = (recentUserImages ?? const <String>[])
//         .where((image) => image.trim().isNotEmpty)
//         .take(2)
//         .toList();
//     final int safeRecentCount = _toInt(recentCount);
//     final int safeTotalLikes = _toInt(totalLikes);
//     final bool hasBubble = safeRecentCount > 0;

//     if (safeImages.isEmpty && !hasBubble && safeTotalLikes <= 0) {
//       return const SizedBox.shrink();
//     }

//     const double avatarSize = 40;
//     const double overlapOffset = 26;

//     final int totalItems = safeImages.length + (hasBubble ? 1 : 0);
//     final double totalWidth = totalItems == 0
//         ? avatarSize
//         : avatarSize + ((totalItems - 1) * overlapOffset);

//     return Positioned(
//       top: 6,
//       right: 10,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: totalWidth,
//             height: avatarSize,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 for (int index = 0; index < safeImages.length; index++)
//                   Positioned(
//                     left: index * overlapOffset,
//                     child: _buildLikeAvatar(
//                       image: safeImages[index],
//                       size: avatarSize,
//                     ),
//                   ),
//                 if (hasBubble)
//                   Positioned(
//                     left: safeImages.length * overlapOffset,
//                     child: Container(
//                       width: avatarSize,
//                       height: avatarSize,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppColor.borderColor,
//                         border: Border.all(
//                           color: const Color(0xFF9C27B0),
//                           width: 3,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF9C27B0).withOpacity(0.6),
//                             blurRadius: 10,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         '+$safeRecentCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             '${_formatLikes(safeTotalLikes)} Likes',
//             style: TextStyle(
//               color: AppColor.spancolor(context),
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildLikeAvatar({
//     required String image,
//     required double size,
//   }) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: Color(0xFF9C27B0), width: 3),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipOval(
//         child: image.startsWith('http')
//             ? Image.network(
//                 image,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Image.asset(
//                     AppImage.placeHolder2Icon,
//                     fit: BoxFit.cover,
//                   );
//                 },
//               )
//             : Image.asset(
//                 AppImage.placeHolder2Icon,
//                 fit: BoxFit.cover,
//               ),
//       ),
//     );
//   }

//   static Widget _cardImageLoadingPlaceholder() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.grey.shade300,
//             Colors.grey.shade200,
//             Colors.grey.shade300,
//           ],
//         ),
//       ),
//       child: const Center(
//         child: SizedBox(
//           width: 28,
//           height: 28,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.4,
//             color: Colors.pinkAccent,
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to build members card
//   static Widget membersCard(
//     BuildContext context,
//     String image,
//     String name,
//     VoidCallback onTap, {
//     Key? key,
//     required bool showHeart,
//     required bool showCross,
//     required String? lastSwipeType,
//     required Function() onMessageTap,
//     required Function() onHeartTap,
//     String? bio,
//     List<String>? vibes,
//     String? distance,
//     String? memberId,
//     Function(dynamic)? onDetailResult,
//   }) {
//     final String safeBio = (bio ?? '').trim();
//     final List<String> safeVibes =
//         (vibes ?? const <String>[]).where((e) => e.trim().isNotEmpty).toList();
//     final bool hasBio = safeBio.isNotEmpty;
//     final bool hasVibes = safeVibes.isNotEmpty;

//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 450),
//       transitionBuilder: (child, animation) => FadeTransition(
//         opacity: animation,
//         child: child,
//       ),
//       child: GestureDetector(
//         onVerticalDragEnd: (details) async {
//           final velocity = details.primaryVelocity ?? 0;

//           if (velocity < -300) {
//             final result = await Navigator.push(
//               context,
//               PageTransition(
//                 type: PageTransitionType.bottomToTop,
//                 child: LikedMemberDetail(memberId: memberId),
//                 duration: const Duration(milliseconds: 400),
//               ),
//             );
//             if (onDetailResult != null) {
//               onDetailResult(result);
//             }
//           }
//         },
//         key: key,
//         onTap: onTap,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 85 / 100,
//           height: MediaQuery.of(context).size.height * 57.5 / 100,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               //! Main Card
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(32),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.2),
//                       blurRadius: 1,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(32),
//                   child: Column(
//                     children: [
//                       //! Image Section
//                       Expanded(
//                         flex: 7,
//                         child: Stack(
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.grey[300]!,
//                                     Colors.grey[200]!,
//                                   ],
//                                 ),
//                               ),
//                               child: image.startsWith('http')
//                                   ? Image.network(
//                                       image,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null) {
//                                           return child;
//                                         }
//                                         return _cardImageLoadingPlaceholder();
//                                       },
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Image.asset(
//                                           AppImage.placeHolder2Icon,
//                                           fit: BoxFit.cover,
//                                         );
//                                       },
//                                     )
//                                   : Image.asset(
//                                       AppImage.placeHolder2Icon,
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                             // Shadow overlay that blends into the info section
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               height: 150,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black,
//                                     ],
//                                     stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       //! Info Section
//                       Expanded(
//                         flex: 3,
//                         child: Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.black,
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 18),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: hasBio
//                                     ? MediaQuery.of(context).size.height *
//                                         .5 /
//                                         100
//                                     : 0,
//                               ),
//                               Text(
//                                 hasBio ? safeBio : '',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: 13,
//                                   height: 1.4,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: (hasBio && hasVibes)
//                                     ? MediaQuery.of(context).size.height *
//                                         .5 /
//                                         100
//                                     : 0,
//                               ),
//                               Text(
//                                 hasVibes ? safeVibes.join(' • ') : "",
//                                 style: const TextStyle(
//                                   color: AppColor.pinkColor,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     .5 /
//                                     100,
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on,
//                                     color: AppColor.pinkColor,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       distance ?? '',
//                                       style: TextStyle(
//                                         color: Colors.grey[500],
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     1 /
//                                     100,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               //! Heart icon for left swipe (green)
//               if (showHeart && lastSwipeType == 'cross')
//                 Positioned(
//                   left: 30,
//                   bottom: -50,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 10 / 100,
//                       height: MediaQuery.of(context).size.width * 10 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.redColor.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(100),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.redColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               //! Cross icon for right swipe (red)
//               if (showCross && lastSwipeType == 'heart')
//                 Positioned(
//                   right: 30,
//                   bottom: -50,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 10 / 100,
//                       height: MediaQuery.of(context).size.width * 10 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.greenColor.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(100),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.greenColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Icon(
//                           Icons.favorite,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               //! Heart Button on Right Side
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 bottom: 100,
//                 child: Center(
//                   child: Container(
//                     width: 40,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       color: const Color(0xff341941).withOpacity(.6),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onHeartTap,
//                             child: Image.asset(AppImage.heart),
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * 2 / 100,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onMessageTap,
//                             child: Image.asset(AppImage.messageIcon),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to build events card
//   static Widget eventsCard(
//     BuildContext context,
//     String image,
//     String name,
//     VoidCallback onTap, {
//     Key? key,
//     required bool showHeart,
//     required bool showCross,
//     required String? lastSwipeType,
//     required Function() onShareTap,
//     required Function() onHeartTap,
//     String? about,
//     List<String>? categories,
//     String? date,
//     String? venueName,
//     String? address,
//     String? distance,
//     List<String>? recentUserImages,
//     int? recentCount,
//     int? totalLikes,
//   }) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 450),
//       transitionBuilder: (child, animation) => FadeTransition(
//         opacity: animation,
//         child: child,
//       ),
//       child: GestureDetector(
//         key: key,
//         onTap: onTap,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 85 / 100,
//           height: MediaQuery.of(context).size.height * 57.5 / 100,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               //! Main Card
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(32),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.2),
//                       blurRadius: 1,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(32),
//                   child: Column(
//                     children: [
//                       //! Image Section
//                       Expanded(
//                         flex: 7,
//                         child: Stack(
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               height: double.infinity,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.grey[300]!,
//                                     Colors.grey[200]!,
//                                   ],
//                                 ),
//                               ),
//                               child: image.startsWith('http')
//                                   ? Image.network(
//                                       image,
//                                       fit: BoxFit.fitHeight,
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Image.asset(
//                                           AppImage.dummyImageIcon,
//                                           fit: BoxFit.fitHeight,
//                                         );
//                                       },
//                                     )
//                                   : Image.asset(
//                                       image,
//                                       fit: BoxFit.fitHeight,
//                                     ),
//                             ),
//                             // Shadow overlay
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               height: 150,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black,
//                                     ],
//                                     stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       //! Info Section
//                       Expanded(
//                         flex: 3,
//                         child: Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.black,
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 18),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     .5 /
//                                     100,
//                               ),
//                               Text(
//                                 about ?? '',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: 13,
//                                   height: 1.4,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     1 /
//                                     100,
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_rounded,
//                                     color: AppColor.pinkColor,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       date ?? '',
//                                       style: const TextStyle(
//                                         color: AppColor.pinkColor,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     .5 /
//                                     100,
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on,
//                                     color: AppColor.pinkColor,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       '${venueName ?? ''}, ${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
//                                       style: TextStyle(
//                                         color: Colors.grey[500],
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     1 /
//                                     100,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               //! Categories on Left Side
//               if (categories != null && categories.isNotEmpty)
//                 Positioned(
//                   top: 2,
//                   left: -5,
//                   child: SizedBox(
//                     height: 41,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 5 / 100,
//                           ),
//                           ...categories.take(2).map((category) => Padding(
//                                 padding: const EdgeInsets.only(right: 5.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     color: AppColor.themeColor.withOpacity(.7),
//                                     border: Border.all(
//                                       color: const Color(0xFF9C27B0),
//                                       width: 1,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: const Color(0xFF9C27B0)
//                                             .withOpacity(0.7),
//                                         blurRadius: 12,
//                                         spreadRadius: 1,
//                                       ),
//                                       BoxShadow(
//                                         color: const Color(0xFF9C27B0)
//                                             .withOpacity(0.3),
//                                         blurRadius: 4,
//                                         spreadRadius: 0,
//                                       ),
//                                     ],
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 2.0, horizontal: 10),
//                                     child: Text(
//                                       category,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//               _buildLikesOverlay(
//                 context,
//                 recentUserImages: recentUserImages,
//                 recentCount: recentCount,
//                 totalLikes: totalLikes,
//               ),

//               //! Heart Button on Right Side
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 bottom: 100,
//                 child: Center(
//                   child: Container(
//                     width: 40,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       color: const Color(0xff341941).withOpacity(.6),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onHeartTap,
//                             child: Image.asset(AppImage.heart),
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * 2 / 100,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onShareTap,
//                             child: Image.asset(AppImage.messageIcon),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               //! Yes - with fade animation
//               if (showHeart && lastSwipeType == 'cross')
//                 Positioned(
//                   right: 30,
//                   top: 80,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 20 / 100,
//                       height: MediaQuery.of(context).size.height * 6 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.greenColor,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.greenColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Yes",
//                           style: TextStyle(
//                             fontFamily: AppFont.fontFamily,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.secondryColor(context),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               //! Nope - with fade animation
//               if (showCross && lastSwipeType == 'heart')
//                 Positioned(
//                   left: 30,
//                   top: 80,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 20 / 100,
//                       height: MediaQuery.of(context).size.height * 6 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.redColor,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.redColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Nope",
//                           style: TextStyle(
//                             fontFamily: AppFont.fontFamily,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.secondryColor(context),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to build venues card
//   static Widget venuesCard(
//     BuildContext context,
//     String image,
//     String name,
//     String venueId,
//     VoidCallback onTap, {
//     Key? key,
//     required bool showHeart,
//     required bool showCross,
//     required String? lastSwipeType,
//     required Function() onShareTap,
//     required Function() onHeartTap,
//     String? about,
//     List<String>? categories,
//     String? timing,
//     String? address,
//     String? distance,
//     List<String>? recentUserImages,
//     int? recentCount,
//     int? totalLikes,
//   }) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 450),
//       transitionBuilder: (child, animation) => FadeTransition(
//         opacity: animation,
//         child: child,
//       ),
//       child: GestureDetector(
//         key: key,
//         onTap: onTap,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 85 / 100,
//           height: MediaQuery.of(context).size.height * 57.5 / 100,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               //! Main Card
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(32),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.2),
//                       blurRadius: 1,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(32),
//                   child: Column(
//                     children: [
//                       //! Image Section
//                       Expanded(
//                         flex: 7,
//                         child: Stack(
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               height: double.infinity,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.grey[300]!,
//                                     Colors.grey[200]!,
//                                   ],
//                                 ),
//                               ),
//                               child: image.startsWith('http')
//                                   ? Image.network(
//                                       image,
//                                       fit: BoxFit.fitHeight,
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Image.asset(
//                                           AppImage.dummyImageIcon,
//                                           fit: BoxFit.fitHeight,
//                                         );
//                                       },
//                                     )
//                                   : Image.asset(
//                                       image,
//                                       fit: BoxFit.fitHeight,
//                                     ),
//                             ),
//                             // Shadow overlay
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               height: 150,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black.withOpacity(0.1),
//                                       Colors.black,
//                                     ],
//                                     stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       //! Info Section
//                       Expanded(
//                         flex: 3,
//                         child: Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.black,
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 18),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     .5 /
//                                     100,
//                               ),
//                               Text(
//                                 about ?? '',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: 13,
//                                   height: 1.4,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     1 /
//                                     100,
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_rounded,
//                                     color: AppColor.pinkColor,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       timing ?? '',
//                                       style: const TextStyle(
//                                         color: AppColor.pinkColor,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     .5 /
//                                     100,
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on,
//                                     color: AppColor.pinkColor,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       '${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
//                                       style: TextStyle(
//                                         color: Colors.grey[500],
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     1 /
//                                     100,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               //! Categories on Left Side
//               if (categories != null && categories.isNotEmpty)
//                 Positioned(
//                   top: 2,
//                   left: -5,
//                   child: SizedBox(
//                     height: 41,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 5 / 100,
//                           ),
//                           ...categories.take(2).map((category) => Padding(
//                                 padding: const EdgeInsets.only(right: 5.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     color: AppColor.themeColor.withOpacity(.7),
//                                     border: Border.all(
//                                         color: const Color(0xFF9C27B0),
//                                         width: 1),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: const Color(0xFF9C27B0)
//                                             .withOpacity(0.7),
//                                         blurRadius: 12,
//                                         spreadRadius: 1,
//                                       ),
//                                       BoxShadow(
//                                         color: const Color(0xFF9C27B0)
//                                             .withOpacity(0.3),
//                                         blurRadius: 4,
//                                         spreadRadius: 0,
//                                       ),
//                                     ],
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 2.0, horizontal: 10),
//                                     child: Text(
//                                       category,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//               _buildLikesOverlay(
//                 context,
//                 recentUserImages: recentUserImages,
//                 recentCount: recentCount,
//                 totalLikes: totalLikes,
//               ),

//               //! Heart Button on Right Side
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 bottom: 100,
//                 child: Center(
//                   child: Container(
//                     width: 40,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       color: const Color(0xff341941).withOpacity(.6),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onHeartTap,
//                             child: Image.asset(AppImage.heart),
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * 2 / 100,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: GestureDetector(
//                             onTap: onShareTap,
//                             child: Image.asset(AppImage.messageIcon),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               //! Yes - with fade animation
//               if (showHeart && lastSwipeType == 'cross')
//                 Positioned(
//                   right: 30,
//                   top: 80,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 20 / 100,
//                       height: MediaQuery.of(context).size.height * 6 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.greenColor,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.greenColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Yes",
//                           style: TextStyle(
//                             fontFamily: AppFont.fontFamily,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.secondryColor(context),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               //! Nope - with fade animation
//               if (showCross && lastSwipeType == 'heart')
//                 Positioned(
//                   left: 30,
//                   top: 80,
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.scale(
//                           scale: 0.8 + (0.2 * value),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 20 / 100,
//                       height: MediaQuery.of(context).size.height * 6 / 100,
//                       decoration: BoxDecoration(
//                         color: AppColor.redColor,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColor.redColor.withOpacity(0.5),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Nope",
//                           style: TextStyle(
//                             fontFamily: AppFont.fontFamily,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.secondryColor(context),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



















