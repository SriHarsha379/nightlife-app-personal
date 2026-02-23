import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/controller/home/home_controller.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../../controller/likedAndBookedEvents/like_booked_event_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_header.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import 'Liked/Liked_event_details.dart';

class ViewAllEventsScreen extends StatefulWidget {
  static String routeName = './ViewAllEventsScreen';
  const ViewAllEventsScreen({super.key});
  @override
  State<ViewAllEventsScreen> createState() => _ViewAllEventsScreenState();
}

class _ViewAllEventsScreenState extends State<ViewAllEventsScreen> {
  List Likedlist = [
    {
      'image': AppImage.roofimg,
      'title': 'Rustic Rooftop Lounge',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'The Brew Corner',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.img3,
      'title': 'Summer Music Festival 2025',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];

  late final ScrollController _likedScrollController;

  @override
  void initState() {
    super.initState();

    _likedScrollController = ScrollController()..addListener(_onLikedScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiked();
    });
  }

  void _fetchLiked() {
    Provider.of<LikedBookedEventController>(context, listen: false)
        .fetchMyEvents(
      context,
      type: 'liked',
      page: 0,
      limit: 10,
    );
  }

  void _onLikedScroll() {
    if (_likedScrollController.position.pixels >=
        _likedScrollController.position.maxScrollExtent - 200) {
      Provider.of<LikedBookedEventController>(context, listen: false)
          .loadMoreLiked(context);
    }
  }

  Future<void> _handleEventDetailResult(dynamic result) async {
    if (result is! Map) return;

    final action = (result['action'] ?? '').toString().trim().toLowerCase();
    final targetEventId = (result['targetEventId'] ?? '').toString().trim();
    if (targetEventId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetEventId, 'event');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetEventId, 'event');
    } else {
      return;
    }

    if (!mounted) return;
    await Provider.of<LikedBookedEventController>(context, listen: false)
        .fetchMyEvents(
      context,
      type: 'liked',
      page: 0,
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
                AppHeader(
                  onPress: () => Navigator.pop(context),
                  text: AppLanguage.likedEvents[language],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Expanded(child: _buildLikedTab(context, size)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikedTab(BuildContext context, Size size) {
    return Consumer<LikedBookedEventController>(
      builder: (context, controller, _) {
        if (controller.isLikedEventsLoading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: AppColor.buttonColor,
              size: 40,
            ),
          );
        }

        final events = controller.likedEvents;

        if (events.isEmpty) {
          return Center(
            child: Text(
              'No liked events yet',
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontFamily: AppFont.fontFamily,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _likedScrollController,
          padding: EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
          itemCount: events.length + (controller.isLikedLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Load more indicator at the bottom
            if (index == events.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 2 / 100),
                child: Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: AppColor.buttonColor,
                    size: 30,
                  ),
                ),
              );
            }

            final event = events[index];
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 1.5 / 100),
              child: _buildLikedVenueCard(context, event, size),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedVenueCard(
      BuildContext context, Map<String, dynamic> event, Size size) {
    return GestureDetector(
      onTap: () async {
        // final result = await Navigator.push(
        //   context,
        //   PageTransition(
        //     type: PageTransitionType.rightToLeftWithFade,
        //     child: VenuePages(
        //       venueId: event['_id'].toString(),
        //       forceDislikeOnly: true,
        //     ),
        //     duration: const Duration(milliseconds: 500),
        //   ),
        // );
        // await _handleVenueDetailResult(result);
      },
      child: Container(
        width: size.width * 90 / 100,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Venue image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.width * 42 / 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl:
                      "${AppConfigProvider.imageUrl}${event['event_image']}",
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    AppImage.dummyImageIcon,
                    fit: BoxFit.cover,
                  ),
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.dotsTriangle(
                      color: AppColor.buttonColor,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
            // Details
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 3 / 100,
                vertical: size.height * 1 / 100,
              ),
              child: Column(
                children: [
                  // Name + heart icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['event_name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 8 / 100,
                        height: size.width * 8 / 100,
                        child: Image.asset(
                          AppImage.liked_heart_icon,
                          fit: BoxFit.cover,
                          // color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.4 / 100),
                  // Time
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 4.5 / 100,
                        height: size.width * 4.5 / 100,
                        child: Image.asset(
                          AppImage.calenderPinkIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size.width * 1 / 100),
                      Text(
                        event['date'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1 / 100),
                  // Address
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 5 / 100,
                        height: size.width * 5 / 100,
                        child: Image.asset(
                          AppImage.locationIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Text(
                            event['address'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: AppColor.secondryColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1.5 / 100),
                  // Events button
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: LikedEventDetail(
                            eventId: event["_id"],
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                      await _handleEventDetailResult(result);
                    },
                    child: Container(
                      height: size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.secondryColor(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          AppLanguage.viewDetailstext[language],
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
