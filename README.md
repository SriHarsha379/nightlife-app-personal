# Night Life (Hii App)

Night Life is a Flutter mobile app for nightlife discovery and social connection.  
Users can discover members, events, and venues, swipe to like/dislike, chat in real time, manage profile preferences, and book events/venues.

## Core Features

- **Authentication**
  - Mobile onboarding + OTP-based flows
  - Email/password login
  - Google Sign-In and Apple Sign-In
- **Personalized onboarding**
  - City, music genres, event preferences, vibe preferences/checks
- **Home feed**
  - Swipe experiences for **Members**, **Events**, and **Venues**
  - Supports likes/dislikes and ad cards
- **Search**
  - Event/venue search with trending keywords
  - Nearby/featured/recommended sections
  - Location + radius based filtering
- **My Space**
  - Members, Venues, and Events sections
  - Booked/liked/past detail flows
- **Real-time chat**
  - Conversation list + direct messaging
  - Shared event interactions and media support
- **Profile management**
  - Edit profile, swipe profile, gallery uploads, vibe/event preference updates
- **Notifications**
  - Firebase Cloud Messaging + local notification routing
  - Deep-link style navigation from notification payloads

## Tech Stack

- **Framework:** Flutter (Dart, SDK `>=3.3.1 <4.0.0`)
- **State Management:** Provider
- **Networking:** `http` + multipart upload helpers
- **Realtime:** `socket_io_client`
- **Auth:** Google Sign-In, Sign in with Apple
- **Maps & Location:** Google Maps, Geolocator, Geocoding
- **Push Notifications:** Firebase Core + FCM + local notifications
- **Persistence:** SharedPreferences

## Project Structure

```text
lib/
├── main.dart                     # App bootstrap, providers, deep links, FCM routing
├── controller/                   # Feature-level controllers (home, search, profile, bookings, etc.)
├── provider/                     # Shared providers (API, socket, user, theme, cache, connectivity)
├── view/                         # UI screens
│   ├── authentication/           # Login/signup/OTP/settings/support
│   ├── bottom navigation/        # Home/Search/Chat/Profile tabs
│   ├── other/                    # Detail and secondary feature screens
│   └── welcomescreens/           # Intro/welcome journey
├── commonWidget/                 # Shared widgets and bottom sheets
└── utilities/                    # Constants, theme, notifications, media/helpers
```

## App Flow (End-to-End)

1. **Launch**
   - `main.dart` initializes Firebase, notifications, app links, and providers.
   - App starts at `Splash`.
2. **Session check**
   - Splash reads cached `user_details`.
   - If valid token exists, user is routed into main app footer tabs.
   - Otherwise, user enters welcome + auth flow.
3. **Auth & onboarding**
   - Login/signup/social login handled through `PostApiProvider`.
   - Navigation branches by verification/profile completion/signup step.
4. **Main app navigation**
   - Footer tabs: **Home**, **Search**, **Chat**, **Profile**.
   - Center action opens My Space entry points (Members/Venues/Events).
5. **Core interactions**
   - Home: swipe-based discovery and actions.
   - Search: discover/filter nearby or recommended venues/events.
   - Chat: socket-based conversations and status updates.
   - Profile: media uploads, preferences, and account settings.
6. **Routing extras**
   - Notification taps and deep links route users to target screens (chat/event/venue/member/notifs).

## API and Backend Integration

- Base API and media URL values are configured in:
  - `lib/utilities/app_config_provider.dart`
- Use environment-specific configuration and placeholders in docs, for example:
  - `apiBaseUrl: https://api.example.com/v1/app/`
  - `imageBaseUrl: https://cdn.example.com/uploads/`
  - Keep URL formatting consistent with your concatenation logic (trailing slash vs no trailing slash).
- `common_api_helper.dart` provides reusable GET/POST/multipart helpers.
- `post_api_provider.dart` orchestrates auth/session and feature API workflows.

## Platform Configuration Notes

### Android

- Permissions and intent filters are defined in:
  - `android/app/src/main/AndroidManifest.xml`
- Firebase is enabled through:
  - `android/app/google-services.json`
  - Gradle Google Services plugin
- A custom URL scheme intent filter is used for app deep-link navigation.
- Required: use a unique, app-specific scheme
  (for example `nightlife://` or `hiiapp://`) to avoid conflicts.
- This is a critical production requirement because generic schemes can be intercepted by other apps.

### iOS

- iOS usage descriptions are configured in:
  - `ios/Runner/Info.plist`
  - Includes location/camera/microphone/photo-library messages.

## Getting Started

### Prerequisites

| Tool / SDK | Required Version |
|---|---|
| Flutter SDK | `>=3.3.1 <4.0.0` |
| Dart SDK | `>=3.3.1 <4.0.0` (bundled with Flutter) |
| Java (JDK) | **17** |
| Gradle (wrapper) | **8.13** |
| Android Gradle Plugin (AGP) | **8.11.1** |
| Kotlin | **2.2.20** |
| Android `compileSdk` / `targetSdk` | **36** |
| Android `minSdk` | **24** |
| Android NDK | **28.2.13676358** |
| iOS minimum deployment target | **14.0** |
| Google Services plugin | **4.3.15** |
| Android Studio | Latest stable recommended |
| Xcode | Compatible with iOS 14+ target |

### Setup

```bash
flutter pub get
```

### Run

```bash
flutter run
```

## Quality Checks

Run these before opening PRs:

```bash
flutter analyze
flutter test
```

## Notes

- The app currently uses hardcoded backend/config references in code (API base URL and platform metadata).  
  For production hardening, move environment-sensitive values to secure configuration management.

## Security Considerations

- Do not publish production API/media endpoints in public documentation.
- Replace README placeholder URLs with deployment-specific values via secure config management before release.
- Use environment variables or build-time secure configuration for sensitive environment settings.
