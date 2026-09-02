import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../controller/book_venue/book_venue_controller.dart';
import '../controller/book_venue/book_venue_details_controller.dart';
import '../controller/blocked_users/blocked_users_controller.dart';
import '../controller/bookingEvent/booking_event_controller.dart';
import '../controller/city/city_preference.dart';
import '../controller/eventBookingDetails/event_booking_details_controller.dart';
import '../controller/eventDetails/events_details_controller.dart';
import '../controller/event_preference/event_preference_controller.dart';
import '../controller/genres/music_genres_controller.dart';
import '../controller/home/home_controller.dart';
import '../controller/invite/invite_event_venue_list_controller.dart';
import '../controller/likedAndBookedEvents/like_booked_event_controller.dart';
import '../controller/members/conversion_list_controller.dart';
import '../controller/members/members_controller.dart';
import '../controller/my_profile/get_my_profile.dart';
import '../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../controller/my_profile/my_visibility_controller.dart';
import '../controller/my_profile/profile_indicator_controller.dart';
import '../controller/notification/notification_controller.dart';
import '../controller/notification/notification_setting_controller.dart';
import '../controller/polls/poll_controller.dart';
import '../controller/contests/contest_controller.dart';
import '../controller/search/search_calender_filter_controller.dart';
import '../controller/search/search_filter_controller.dart';
import '../controller/support/faq_controller.dart';
import '../controller/venues/my_venues_controller.dart';
import '../controller/venues/venues_details_controller.dart';
import '../controller/vibe_check/vibe_check_controller.dart';
import '../controller/vibe_preference/vibe_prefernce_controller.dart';
import 'darkmode_provider.dart';
import 'post_api_provider.dart';
import 'socket_provider.dart';
import 'user_chat_socket_provider.dart';
import 'user_controller.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    ChangeNotifierProvider(create: (_) => SocketProvider()),
    ChangeNotifierProxyProvider<SocketProvider, UserChatSocketProvider>(
      create: (ctx) => UserChatSocketProvider(
        Provider.of<SocketProvider>(ctx, listen: false),
      ),
      update: (ctx, socketProvider, previous) =>
      previous!..update(socketProvider),
    ),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => PostApiProvider()),
    ChangeNotifierProvider(create: (_) => VibeCheckController()),
    ChangeNotifierProvider(create: (_) => UserController()),
    ChangeNotifierProvider(create: (_) => CityPreferenceController()),
    ChangeNotifierProvider(create: (_) => MusicGenresController()),
    ChangeNotifierProvider(create: (_) => EventPreferenceController()),
    ChangeNotifierProvider(create: (_) => VibePreferenceController()),
    ChangeNotifierProvider(create: (_) => VibeCheckController()),
    ChangeNotifierProvider(create: (_) => HomeController()),
    ChangeNotifierProvider(create: (_) => InviteEventVenueListController()),
    ChangeNotifierProvider(create: (_) => ProfileController()),
    ChangeNotifierProvider(create: (_) => GetMySwipeProfileController()),
    ChangeNotifierProvider(create: (_) => MyVisibilityController()),
    ChangeNotifierProvider(create: (_) => FaqController()),
    ChangeNotifierProvider(create: (_) => MembersController()),
    ChangeNotifierProvider(create: (_) => ConversionListController()),
    ChangeNotifierProvider(create: (_) => VenuesDetailsController()),
    ChangeNotifierProvider(create: (_) => BookVenueController()),
    ChangeNotifierProvider(create: (_) => MyVenuesController()),
    ChangeNotifierProvider(create: (_) => VenuesBookingDetailsController()),
    ChangeNotifierProvider(create: (_) => SearchFilterController()),
    ChangeNotifierProvider(create: (_) => CalendarController()),
    ChangeNotifierProvider(create: (_) => EventDetailsController()),
    ChangeNotifierProvider(create: (_) => BookingEventDetails()),
    ChangeNotifierProvider(create: (_) => LikedBookedEventController()),
    ChangeNotifierProvider(create: (_) => EventsBookingDetailsController()),
    ChangeNotifierProvider(create: (_) => NotificationController()),
    ChangeNotifierProvider(create: (_) => NotificationSettingController()),
    ChangeNotifierProvider(create: (_) => MyProfleCompltetionController()),
    ChangeNotifierProvider(create: (_) => BlockedUsersController()),
    ChangeNotifierProvider(create: (_) => PollController()),
    ChangeNotifierProvider(create: (_) => ContestController()),
  ];
}