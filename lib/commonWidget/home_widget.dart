import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:night_life/utilities/url_utils.dart';
import '../utilities/app_color.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../view/other/MySplashSection/MembersSection/member_liked_details.dart';

class HomeWidget {
  int selectedIndex = 0;

  // Formats a raw ISO date (e.g. "2026-08-22") into "22nd Aug, Saturday" -
  // matching Liked_event_details.dart's formatDateWithSuffix exactly, so
  // the event preview card and the event detail screen show the date in
  // the identical style rather than drifting apart.
  static String _formatEventDateWithSuffix(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    DateTime date;
    try {
      date = DateTime.parse(isoDate);
    } catch (_) {
      return '';
    }

    final day = DateFormat('d').format(date);
    final month = DateFormat('MMM').format(date);
    final weekday = DateFormat('EEEE').format(date);

    return '${_dayWithSuffix(int.parse(day))} $month, $weekday';
  }

  static String _dayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  // The swipe card (members/events/venues) used to be sized as a flat 57.5%
  // of total screen height. That works out fine on whatever device this was
  // designed against, but on phones with a different aspect ratio (many
  // budget Android phones, e.g. Moto G-series, are taller/narrower than a
  // typical iPhone) the extra vertical space just becomes an empty gap
  // between the card and the floating nav bar, instead of the card growing
  // to use it.
  //
  // Fix: instead of "card = 57.5% of screen height" (scales proportionally,
  // wrong), compute it as "card = screen height minus a fixed chrome
  // estimate" (the header/search/tabs above + floating nav bar below don't
  // meaningfully grow with screen height, so treating them as a roughly
  // constant pixel amount - not a percentage - means any extra screen
  // height on a taller device goes to the card itself, closing the gap).
  //
  // 359 is calibrated against a ~844pt-tall reference screen where the old
  // 57.5%/42.5% split (card/chrome) was presumably tuned: 844 * 0.425 ≈ 359.
  static double swipeCardHeight(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    const double estimatedChromeHeight = 359;
    return (screenHeight - estimatedChromeHeight)
        .clamp(320.0, screenHeight * 0.78);
  }

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
      height: swipeCardHeight(context),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              // Outline so the card reads as a distinct card against dark
              // backgrounds instead of blending in - it previously had
              // only soft shadows, no actual border.
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
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
              opacity: 1.0,
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: size.width * 0.13,
            height: size.width * 0.13,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.95)
                  : Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? color : color.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isActive ? 0.5 : 0.25),
                  blurRadius: isActive ? 20 : 10,
                  spreadRadius: isActive ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: size.width * 0.065,
              ),
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
        double dragPercentX = 0,
        required bool showHeart,
        required bool showCross,
        required String? lastSwipeType,
        required Function() onRejectTap,
        required Function() onMessageTap,
        required Function() onHeartTap,
        String? bio,
        List<String>? musicGenres,
        String? distance,
        String? memberId,
        Function(dynamic)? onDetailResult,
      }) {
    final String safeBio = (bio ?? '').trim();
    // Vibe check has been removed - this now shows the member's
    // selected music genres instead.
    final List<String> safeVibes =
    (musicGenres ?? const <String>[]).where((e) => e.trim().isNotEmpty).toList();
    final bool hasBio = safeBio.isNotEmpty;
    final bool hasVibes = safeVibes.isNotEmpty;
    // Live drag feedback: the color wash and beside-card glow fade in
    // progressively as the card is actively being dragged.
    // dragPercentX is the ratio of horizontal drag to the swipe threshold,
    // as a percentage - positive while dragging right, negative while
    // dragging left.
    final bool isDraggingRight = dragPercentX > 1;
    final bool isDraggingLeft = dragPercentX < -1;
    // Ramps to full opacity by ~25 units of drag, so the badge commits to
    // fully visible almost as soon as the drag starts, rather than staying
    // faint through most of the gesture.
    final double dragOpacity = (dragPercentX.abs() / 25).clamp(0.0, 1.0);
    // Each badge sits at a dim 0.55 "hint" opacity at rest (visible before
    // any swipe starts). Once a drag commits to one direction, that side
    // ramps up to fully lit while the OPPOSITE side fades toward 0 - e.g.
    // dragging left brightens the reject badge and hides the accept one,
    // so the two never appear active/contradictory at the same time.
    const double restBadgeOpacity = 0.88;
    final double rejectBadgeOpacity = isDraggingLeft
        ? 1.0
        : (isDraggingRight
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);
    final double acceptBadgeOpacity = isDraggingRight
        ? 1.0
        : (isDraggingLeft
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);

    // Swipe tilt - the card rotates a few degrees toward the drag
    // direction as it's dragged (like Tinder/Bumble), pivoting from the
    // bottom so it reads as a natural physical tilt rather than a flat
    // slide. Capped at 10 degrees so it stays a light touch, not a spin.
    final double rotationAngle =
        (dragPercentX / 100).clamp(-1.0, 1.0) * (10 * math.pi / 180);

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
        child: Transform.rotate(
          angle: rotationAngle,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: (isDraggingLeft || isDraggingRight)
                  ? [
                BoxShadow(
                  color: (isDraggingLeft
                      ? AppColor.redColor
                      : AppColor.greenColor)
                      .withOpacity(dragOpacity * 0.6),
                  blurRadius: 45,
                  spreadRadius: 10,
                ),
              ]
                  : [],
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 85 / 100,
              height: swipeCardHeight(context),
              child: Stack(
                clipBehavior: Clip.hardEdge,
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
                              child: SingleChildScrollView(
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
                                      height: hasBio
                                          ? MediaQuery.of(context).size.height *
                                          .5 /
                                          100
                                          : 0,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: AppColor.pinkColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: distance ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                // Selected music genres shown
                                                // right alongside the location,
                                                // instead of their own line.
                                                if (hasVibes)
                                                  TextSpan(
                                                    text:
                                                    '  •  ${safeVibes.join(', ')}',
                                                    style: const TextStyle(
                                                      color: AppColor.pinkColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Trailing spacer shrunk (was 1%) - same
                                    // fix as eventsCard/venuesCard, this was
                                    // tight enough to risk a small bottom
                                    // overflow on longer member cards.
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height *
                                          .3 /
                                          100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  //! Tags on Left Side - same purple pill design as the
                  //! events/venues cards, reusing the member's music genres
                  //! as the tag content since that's the real per-member
                  //! data already available here.
                  if (safeVibes.isNotEmpty)
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
                              ...safeVibes.take(2).map((tag) => Padding(
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
                                      tag,
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

                  // Swipe direction color wash - tints the whole card while
                  // dragging, red toward reject (left) and green toward
                  // accept (right). Fades in with drag distance and clips to
                  // the same rounded corners as the card itself. The matching
                  // glow beside the card is painted by the AnimatedContainer
                  // wrapping this SizedBox.
                  if (isDraggingLeft || isDraggingRight)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            color: (isDraggingLeft
                                ? AppColor.redColor
                                : AppColor.greenColor)
                                .withOpacity(dragOpacity * 0.45),
                          ),
                        ),
                      ),
                    ),

                  // Reject indicator - matches the client's reference image:
                  // a solid red circle with a plain white X inside, plus a
                  // separate small arrow sitting just outside the circle
                  // pointing further in the swipe direction. This replaces
                  // the earlier combined arrow-through-icon line-art design.
                  Builder(builder: (context) {
                    final double circleDiameter =
                        MediaQuery.of(context).size.width * 0.105;
                    const double edgeInset = 14;

                    return Positioned(
                      top: edgeInset, // kept at top for members - genre tags are optional, so it doesn't always need clearance
                      left: edgeInset,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: rejectBadgeOpacity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: circleDiameter,
                                height: circleDiameter,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.redColor,
                                  // White ring plus a dark drop shadow so the
                                  // badge stays visible even when the photo
                                  // behind it is a similar red tone.
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    // Crisp black outline ring, drawn just outside the
                                    // white ring, for maximum contrast on any background.
                                    const BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 0,
                                      spreadRadius: 2.5,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.45),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 3),
                                    ),
                                    BoxShadow(
                                      color: AppColor.redColor.withOpacity(
                                          isDraggingLeft ? 0.8 : 0.5),
                                      blurRadius: isDraggingLeft ? 18 : 10,
                                      spreadRadius: isDraggingLeft ? 1 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: circleDiameter * 0.55,
                                ),
                              ),
                              const SizedBox(width: 4),
                              _doubleChevron(
                                size: circleDiameter * 0.85,
                                pointRight: false,
                                fillColor: AppColor.redColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Accept indicator - mirrored: arrow first (pointing
                  // right, further out), then the solid green circle with a
                  // plain white heart inside.
                  Builder(builder: (context) {
                    final double circleDiameter =
                        MediaQuery.of(context).size.width * 0.105;
                    const double edgeInset = 14;

                    return Positioned(
                      bottom: 175,
                      right: edgeInset,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: acceptBadgeOpacity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _doubleChevron(
                                size: circleDiameter * 0.85,
                                pointRight: true,
                                fillColor: AppColor.greenColor,
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: circleDiameter,
                                height: circleDiameter,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.greenColor,
                                  // White ring plus a dark drop shadow so the
                                  // badge stays visible even when the photo
                                  // behind it is a similar green tone.
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    // Crisp black outline ring, drawn just outside the
                                    // white ring, for maximum contrast on any background.
                                    const BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 0,
                                      spreadRadius: 2.5,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.45),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 3),
                                    ),
                                    BoxShadow(
                                      color: AppColor.greenColor.withOpacity(
                                          isDraggingRight ? 0.8 : 0.5),
                                      blurRadius: isDraggingRight ? 18 : 10,
                                      spreadRadius: isDraggingRight ? 1 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: circleDiameter * 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

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
                                onTap: () {
                                  _showHeartBurst(context);
                                  onHeartTap();
                                },
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
        double dragPercentX = 0,
        required bool showHeart,
        required bool showCross,
        required String? lastSwipeType,
        required Function() onRejectTap,
        required Function() onShareTap,
        required Function() onHeartTap,
        String? about,
        List<String>? categories,
        String? date,
        // Raw ISO start_date (e.g. "2026-08-22") - formatted client-side
        // into "22nd Aug, Saturday" to match the event detail screen's
        // date style exactly, shown as its own row with a calendar icon.
        String? eventDate,
        String? venueName,
        String? address,
        String? distance,
        List<String>? recentUserImages,
        int? recentCount,
        int? totalLikes,
      }) {
    // Live drag feedback, same behavior as the members card: badges sit at
    // a dim "hint" opacity at rest and ramp to fully lit on the active
    // swipe side while fading the opposite side out.
    final bool isDraggingRight = dragPercentX > 1;
    final bool isDraggingLeft = dragPercentX < -1;
    final double dragOpacity = (dragPercentX.abs() / 25).clamp(0.0, 1.0);
    const double restBadgeOpacity = 0.88;
    final double rejectBadgeOpacity = isDraggingLeft
        ? 1.0
        : (isDraggingRight
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);
    final double acceptBadgeOpacity = isDraggingRight
        ? 1.0
        : (isDraggingLeft
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);

    // Swipe tilt - the card rotates a few degrees toward the drag
    // direction as it's dragged (like Tinder/Bumble), pivoting from the
    // bottom so it reads as a natural physical tilt rather than a flat
    // slide. Capped at 10 degrees so it stays a light touch, not a spin.
    final double rotationAngle =
        (dragPercentX / 100).clamp(-1.0, 1.0) * (10 * math.pi / 180);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Transform.rotate(
          angle: rotationAngle,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 85 / 100,
            height: swipeCardHeight(context),
            child: Stack(
              clipBehavior: Clip.hardEdge,
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
                            child: SingleChildScrollView(
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
                                  // New: formatted date row ("22nd Aug, Saturday")
                                  // matching the event detail screen's calendar
                                  // row exactly, via the same formatting logic.
                                  Builder(builder: (context) {
                                    final formattedDate =
                                    _formatEventDateWithSuffix(eventDate);
                                    if (formattedDate.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppColor.pinkColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                color: AppColor.pinkColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        color: AppColor.pinkColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
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
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${venueName ?? ''}, ${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Trailing spacer removed - it was purely
                                  // decorative bottom padding, and on longer
                                  // event cards (full 2-line description +
                                  // date + time + location all present) it
                                  // was just enough to push the content past
                                  // the available height, causing a small
                                  // bottom overflow.
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .3 /
                                        100,
                                  ),
                                ],
                              ),
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

                // Swipe direction color wash - tints the whole card while
                // dragging, red toward reject (left) and green toward
                // accept (right). Same effect as the members card, just
                // added here too so all three cards behave identically.
                if (isDraggingLeft || isDraggingRight)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          color: (isDraggingLeft
                              ? AppColor.redColor
                              : AppColor.greenColor)
                              .withOpacity(dragOpacity * 0.45),
                        ),
                      ),
                    ),
                  ),

                // Reject indicator - same design as the members card: a
                // solid red circle with a white X, plus an arrow pointing
                // further in the swipe direction.
                Builder(builder: (context) {
                  final double circleDiameter =
                      MediaQuery.of(context).size.width * 0.105;
                  const double edgeInset = 14;

                  return Positioned(
                    top: edgeInset + 46, // pushed down to clear the tag row
                    left: edgeInset,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: rejectBadgeOpacity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.redColor,
                                // White ring plus a dark drop shadow so the badge
                                // stays visible even when the photo behind it is a
                                // similar tone.
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  // Crisp black outline ring, drawn just outside the
                                  // white ring, for maximum contrast on any background.
                                  const BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 0,
                                    spreadRadius: 2.5,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: AppColor.redColor.withOpacity(
                                        isDraggingLeft ? 0.8 : 0.5),
                                    blurRadius: isDraggingLeft ? 18 : 10,
                                    spreadRadius: isDraggingLeft ? 1 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: circleDiameter * 0.55,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _doubleChevron(
                              size: circleDiameter * 0.85,
                              pointRight: false,
                              fillColor: AppColor.redColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Accept indicator - mirrored: arrow first, then the solid
                // green circle with a white heart.
                Builder(builder: (context) {
                  final double circleDiameter =
                      MediaQuery.of(context).size.width * 0.105;
                  const double edgeInset = 14;

                  return Positioned(
                    bottom: 175,
                    right: edgeInset,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: acceptBadgeOpacity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _doubleChevron(
                              size: circleDiameter * 0.85,
                              pointRight: true,
                              fillColor: AppColor.greenColor,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.greenColor,
                                // White ring plus a dark drop shadow so the badge
                                // stays visible even when the photo behind it is a
                                // similar tone.
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  // Crisp black outline ring, drawn just outside the
                                  // white ring, for maximum contrast on any background.
                                  const BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 0,
                                    spreadRadius: 2.5,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: AppColor.greenColor.withOpacity(
                                        isDraggingRight ? 0.8 : 0.5),
                                    blurRadius: isDraggingRight ? 18 : 10,
                                    spreadRadius: isDraggingRight ? 1 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: circleDiameter * 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

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
                              onTap: () {
                                _showHeartBurst(context);
                                onHeartTap();
                              },
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
        double dragPercentX = 0,
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
    // Live drag feedback, same behavior as the members card: badges sit at
    // a dim "hint" opacity at rest and ramp to fully lit on the active
    // swipe side while fading the opposite side out.
    final bool isDraggingRight = dragPercentX > 1;
    final bool isDraggingLeft = dragPercentX < -1;
    final double dragOpacity = (dragPercentX.abs() / 25).clamp(0.0, 1.0);
    const double restBadgeOpacity = 0.88;
    final double rejectBadgeOpacity = isDraggingLeft
        ? 1.0
        : (isDraggingRight
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);
    final double acceptBadgeOpacity = isDraggingRight
        ? 1.0
        : (isDraggingLeft
        ? (restBadgeOpacity * (1 - dragOpacity)).clamp(0.0, restBadgeOpacity)
        : restBadgeOpacity);

    // Swipe tilt - the card rotates a few degrees toward the drag
    // direction as it's dragged (like Tinder/Bumble), pivoting from the
    // bottom so it reads as a natural physical tilt rather than a flat
    // slide. Capped at 10 degrees so it stays a light touch, not a spin.
    final double rotationAngle =
        (dragPercentX / 100).clamp(-1.0, 1.0) * (10 * math.pi / 180);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Transform.rotate(
          angle: rotationAngle,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 85 / 100,
            height: swipeCardHeight(context),
            child: Stack(
              clipBehavior: Clip.hardEdge,
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
                            child: SingleChildScrollView(
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
                                      const SizedBox(width: 6),
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
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${address ?? ''}${distance != null && distance.isNotEmpty ? ' • $distance' : ''}',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Trailing spacer shrunk (was 1%) - same fix
                                  // as eventsCard, this was tight enough to
                                  // cause a small bottom overflow on longer
                                  // venue cards.
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .3 /
                                        100,
                                  ),
                                ],
                              ),
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

                // Swipe direction color wash - tints the whole card while
                // dragging, red toward reject (left) and green toward
                // accept (right). Same effect as the members card, just
                // added here too so all three cards behave identically.
                if (isDraggingLeft || isDraggingRight)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          color: (isDraggingLeft
                              ? AppColor.redColor
                              : AppColor.greenColor)
                              .withOpacity(dragOpacity * 0.45),
                        ),
                      ),
                    ),
                  ),

                // Reject indicator - same design as the members card: a
                // solid red circle with a white X, plus an arrow pointing
                // further in the swipe direction.
                Builder(builder: (context) {
                  final double circleDiameter =
                      MediaQuery.of(context).size.width * 0.105;
                  const double edgeInset = 14;

                  return Positioned(
                    top: edgeInset + 46, // pushed down to clear the venue category tag
                    left: edgeInset,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: rejectBadgeOpacity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.redColor,
                                // White ring plus a dark drop shadow so the badge
                                // stays visible even when the photo behind it is a
                                // similar tone.
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  // Crisp black outline ring, drawn just outside the
                                  // white ring, for maximum contrast on any background.
                                  const BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 0,
                                    spreadRadius: 2.5,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: AppColor.redColor.withOpacity(
                                        isDraggingLeft ? 0.8 : 0.5),
                                    blurRadius: isDraggingLeft ? 18 : 10,
                                    spreadRadius: isDraggingLeft ? 1 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: circleDiameter * 0.55,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _doubleChevron(
                              size: circleDiameter * 0.85,
                              pointRight: false,
                              fillColor: AppColor.redColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Accept indicator - mirrored: arrow first, then the solid
                // green circle with a white heart.
                Builder(builder: (context) {
                  final double circleDiameter =
                      MediaQuery.of(context).size.width * 0.105;
                  const double edgeInset = 14;

                  return Positioned(
                    bottom: 175,
                    right: edgeInset,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: acceptBadgeOpacity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _doubleChevron(
                              size: circleDiameter * 0.85,
                              pointRight: true,
                              fillColor: AppColor.greenColor,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.greenColor,
                                // White ring plus a dark drop shadow so the badge
                                // stays visible even when the photo behind it is a
                                // similar tone.
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  // Crisp black outline ring, drawn just outside the
                                  // white ring, for maximum contrast on any background.
                                  const BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 0,
                                    spreadRadius: 2.5,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: AppColor.greenColor.withOpacity(
                                        isDraggingRight ? 0.8 : 0.5),
                                    blurRadius: isDraggingRight ? 18 : 10,
                                    spreadRadius: isDraggingRight ? 1 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: circleDiameter * 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

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
                              onTap: () {
                                _showHeartBurst(context);
                                onHeartTap();
                              },
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
      ),
    );
  }

  // Payoff moment for a "like" tap - a heart pops in with a bounce, small
  // heart particles fly outward, and it all fades out. Shown via the top
  // level Overlay (not local widget state) so it plays fully and cleans
  // itself up regardless of what happens to the card underneath it (swipe
  // away, navigation, etc.) right after the tap.
  static void _showHeartBurst(BuildContext context) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: _HeartBurst(onCompleted: () => entry.remove()),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
  }

  // Double-chevron shape matching the client's reference asset exactly -
  // a flat-backed notched chevron plus a plain triangle behind it,
  // drawn as a custom path (rather than a stock Material icon).
  // fillColor defaults to white; pass Colors.black for the dark version.
  static Widget _doubleChevron({
    required double size,
    required bool pointRight,
    Color fillColor = Colors.white,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DoubleChevronPainter(
        pointRight: pointRight,
        fillColor: fillColor,
      ),
    );
  }

  // Quick variant for use on light/white backgrounds - black arrow.
  static Widget _doubleChevronOnLight({
    required double size,
    required bool pointRight,
  }) =>
      _doubleChevron(size: size, pointRight: pointRight, fillColor: Colors.black);

  // Quick variant for use on dark/black backgrounds - white arrow.
  static Widget _doubleChevronOnDark({
    required double size,
    required bool pointRight,
  }) =>
      _doubleChevron(size: size, pointRight: pointRight, fillColor: Colors.white);
}

class _DoubleChevronPainter extends CustomPainter {
  final bool pointRight;
  final Color fillColor;

  _DoubleChevronPainter({
    required this.pointRight,
    this.fillColor = Colors.black,
  });

  // The flat-backed chevron (has a concave notch cut into its back edge).
  Path _chevron(double dx, double cw, double h) {
    final path = Path();
    path.moveTo(dx, 0);
    path.lineTo(dx + cw * 0.55, 0);
    path.lineTo(dx + cw, h * 0.5);
    path.lineTo(dx + cw * 0.55, h);
    path.lineTo(dx, h);
    path.lineTo(dx + cw * 0.42, h * 0.5);
    path.close();
    return path;
  }

  // The plain triangle behind it - no flat back, no notch, just a point,
  // matching the second shape in the reference image exactly.
  Path _triangle(double dx, double cw, double h) {
    final path = Path();
    path.moveTo(dx, h * 0.06);
    path.lineTo(dx + cw, h * 0.5);
    path.lineTo(dx, h * 0.94);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Notched chevron plus a plain triangle behind it, separated by a
    // clear gap (not overlapping like the earlier messy version) - this
    // matches the reference image's two distinct shapes while each one
    // stays crisp on its own.
    final double cw1 = w * 0.4;
    final double cw2 = w * 0.36;
    final double gap = w * 0.16;
    final Path shape = Path()
      ..addPath(_chevron(0, cw1, h), Offset.zero)
      ..addPath(_triangle(cw1 + gap, cw2, h), Offset.zero);

    final Path path;
    if (!pointRight) {
      final matrix = Matrix4.identity()
        ..translate(w, 0.0)
        ..scale(-1.0, 1.0);
      path = shape.transform(matrix.storage);
    } else {
      path = shape;
    }

    // Crisp two-tone outline matching the circle badges: a black ring on
    // the outside, a white ring just inside it, then the colored fill -
    // same treatment as the reject/accept circles, not just a soft blur.
    final blackOutline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.16
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, blackOutline);

    final whiteOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, whiteOutline);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _DoubleChevronPainter oldDelegate) =>
      oldDelegate.pointRight != pointRight ||
          oldDelegate.fillColor != fillColor;
}

// The actual "like" payoff animation: a big heart pops in with a bounce,
// small heart particles fly outward and fade, then the whole thing fades
// out. Self-contained and self-removing (via onCompleted) - shown through
// an OverlayEntry by HomeWidget._showHeartBurst rather than being part of
// any single card's widget tree.
class _HeartBurst extends StatefulWidget {
  final VoidCallback onCompleted;

  const _HeartBurst({required this.onCompleted});

  @override
  State<_HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<_HeartBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _particleCount = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value;

        // Main heart: bounces in over the first half, holds, then fades
        // out over the last quarter.
        final double mainScale =
        t < 0.5 ? Curves.elasticOut.transform(t / 0.5) : 1.0;
        final double mainOpacity =
        (t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25)).clamp(0.0, 1.0);

        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < _particleCount; i++) _particle(i, t),
              Opacity(
                opacity: mainOpacity,
                child: Transform.scale(
                  scale: mainScale,
                  child: const Icon(
                    Icons.favorite,
                    color: AppColor.greenColor,
                    size: 88,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // A single small heart flying outward from the center along its own
  // fixed angle, fading and shrinking as it travels.
  Widget _particle(int index, double t) {
    final double angle = (index / _particleCount) * 2 * math.pi;
    final double travel = Curves.easeOut.transform(t);
    final double distance = 85 * travel;
    final double opacity = (1 - t).clamp(0.0, 1.0);
    final double size = (18 - 8 * t).clamp(6.0, 18.0);

    return Transform.translate(
      offset: Offset(math.cos(angle) * distance, math.sin(angle) * distance),
      child: Opacity(
        opacity: opacity,
        child: Icon(
          Icons.favorite,
          color: AppColor.pinkColor,
          size: size,
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
//           height: swipeCardHeight(context),
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
//           height: swipeCardHeight(context),
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
//           height: swipeCardHeight(context),
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