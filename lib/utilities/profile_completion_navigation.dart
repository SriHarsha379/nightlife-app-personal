import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/my_profile/profile_indicator_controller.dart';
import '../view/authentication/edit_profile_screen.dart';
import '../view/bottom navigation/profile1.dart';
import '../view/other/edit_hobbies.dart';
import '../view/other/edit_vibe_check.dart';
import 'app_snack_bar_toast_message.dart';

/// Maps the stable `field` keys returned by the backend's
/// `calculateProfileCompletion` (see profile_indicator_controller.dart /
/// common/profile_complete_status) to a short, member-facing label, used
/// for the "next up" toast shown when chaining from one missing field to
/// the next.
String profileCompletionFieldLabel(String field) {
  switch (field) {
    case 'gallery':
      return 'Add a few more photos/videos';
    case 'instagram':
      return 'Connect Instagram';
    case 'hobbies':
      return 'Add a hobby';
    case 'vibe_check':
      return 'Answer Vibe Check questions';
    case 'bio':
      return 'Complete your bio';
    default:
      return 'Finish your profile';
  }
}

/// Pushes whichever screen actually lets the member fix `field`.
void navigateToProfileCompletionField(BuildContext context, String? field) {
  switch (field) {
    case 'bio':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfile(focusField: 'bio'),
        ),
      );
      return;
    case 'instagram':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfile(focusField: 'instagram'),
        ),
      );
      return;
    case 'hobbies':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const EditHobbiesScreen(cameFromCompletionPrompt: true),
        ),
      );
      return;
    case 'gallery':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const Profile1(autoOpenMediaPicker: true),
        ),
      );
      return;
    case 'vibe_check':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const EditVibeCheckScreen(cameFromCompletionPrompt: true),
        ),
      );
      return;
    default:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfile()),
      );
      return;
  }
}

/// Called after a member finishes one profile-completion step (saving
/// bio/instagram, adding a hobby, uploading media). Re-fetches the
/// member's completion status; if something else is still missing,
/// nudges them straight there; otherwise lets them know they're done.
/// `justCompletedField` is skipped even if the backend response hasn't
/// caught up yet, so we never bounce them right back to the field they
/// just finished.
///
/// A no-op unless `cameFromCompletionPrompt` is true — this chaining is
/// only meant to kick in when the member arrived via a "profile X%
/// complete" notification/prompt, not on every ordinary profile edit.
Future<void> continueToNextMissingProfileField(
    BuildContext context, {
      required bool cameFromCompletionPrompt,
      String? justCompletedField,
    }) async {
  if (!cameFromCompletionPrompt) return;

  final controller =
  Provider.of<MyProfleCompltetionController>(context, listen: false);
  await controller.fetchMyProfleCompltetion(context);
  if (!context.mounted) return;

  final remainingFields = controller.completionFields;
  final next = remainingFields.firstWhere(
        (f) => f != justCompletedField,
    orElse: () => '',
  );

  if (next.isEmpty) {
    SnackBarToastMessage.success(context, "Nice — your profile is complete!");
    return;
  }

  SnackBarToastMessage.info(
    context,
    "Next up: ${profileCompletionFieldLabel(next)}",
  );
  navigateToProfileCompletionField(context, next);
}