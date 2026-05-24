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

Everything you need before you can run the app for the first time.

#### Version reference table

| Tool / SDK | Required version | Notes |
|---|---|---|
| **Flutter SDK** | `>=3.3.1 <4.0.0` (recommend latest stable 3.x) | Dart SDK is bundled — no separate install |
| **Dart SDK** | `>=3.3.1 <4.0.0` | Comes with Flutter |
| **Java JDK** | **17** | Use OpenJDK 17 or Eclipse Temurin 17 |
| **Gradle wrapper** | **8.13** | Managed automatically by the wrapper |
| **Android Gradle Plugin (AGP)** | **8.11.1** | Declared in `android/settings.gradle` |
| **Kotlin** | **2.2.20** | Declared in `android/settings.gradle` |
| **Android `compileSdk` / `targetSdk`** | **36** (Android 16) | Install via Android Studio SDK Manager |
| **Android `minSdk`** | **24** (Android 7.0) | Devices below Android 7 are not supported |
| **Android NDK** | **28.2.13676358** | Install via Android Studio SDK Manager |
| **Android Studio** | **Meerkat (2024.3) or later** | Earlier versions may not support AGP 8.x |
| **Xcode** | **15 or later** | Required for iOS builds; macOS only |
| **CocoaPods** | **1.14 or later** | Required for iOS dependency management |
| **iOS deployment target** | **14.0** | Devices below iOS 14 are not supported |

---

### Step-by-step local setup

#### 1. Install Flutter

1. Download the Flutter SDK from <https://docs.flutter.dev/get-started/install> and choose your OS.
2. Extract it to a folder (e.g. `~/flutter` on macOS/Linux or `C:\flutter` on Windows).
3. Add the `flutter/bin` directory to your system `PATH`.
4. Run `flutter doctor` in a terminal — it will tell you exactly what is still missing.

#### 2. Install Java 17

Flutter's Android toolchain requires **JDK 17** (not 8, 11, or 21).

- **macOS/Linux:** Use [SDKMAN](https://sdkman.io/) — `sdk install java 17-tem`
- **Windows:** Download [Eclipse Temurin 17](https://adoptium.net/temurin/releases/?version=17) and install.
- Set the `JAVA_HOME` environment variable to the JDK 17 installation directory.

#### 3. Install Android Studio (Meerkat 2024.3+)

1. Download from <https://developer.android.com/studio>.
2. During installation, include **Android SDK**, **Android SDK Platform**, and the **Android Virtual Device (AVD)**.
3. After installation open **SDK Manager** (`Tools → SDK Manager`) and install:
    - **SDK Platforms tab:** Android 16 (API level 36)
    - **SDK Tools tab:** Check and install **NDK (Side by side)** version `28.2.13676358`
4. In **SDK Manager → SDK Tools**, ensure **Android SDK Build-Tools 36** is also installed.

> **Tip:** If `flutter doctor` shows Android toolchain issues, run:
> ```bash
> flutter doctor --android-licenses
> ```
> and accept all licences.

#### 4. (iOS only) Install Xcode and CocoaPods

> **macOS only.** Skip this section if you are only building for Android.

1. Install **Xcode 15+** from the Mac App Store.
2. Open Xcode, accept the licence agreement, and install the command-line tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. Install CocoaPods (requires Ruby):
   ```bash
   sudo gem install cocoapods
   ```
4. Inside the `ios/` directory run:
   ```bash
   pod install
   ```

#### 5. Add required Firebase configuration files

This app uses Firebase. Each platform needs its own config file (these are **not** committed to the repository because they contain project-specific credentials).

| Platform | File to create | Where to put it |
|---|---|---|
| Android | `google-services.json` | `android/app/google-services.json` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

Obtain these files from your Firebase project console under **Project Settings → Your apps**.

#### 6. Install Flutter dependencies

```bash
flutter pub get
```

#### 7. Run the app

Connect a physical device or start an emulator/simulator, then:

```bash
flutter run
```

To target a specific device when you have more than one connected:

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

---

### Verify your environment

Run Flutter's built-in health check at any time:

```bash
flutter doctor -v
```

All items should show a green ✓ before the app can be built and run successfully.

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
