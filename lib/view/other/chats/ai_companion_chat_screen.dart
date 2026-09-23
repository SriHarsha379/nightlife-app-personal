import 'package:flutter/material.dart';

import '../../../commonWidget/ai_assistant_launcher.dart';
import '../../../utilities/app_image.dart';

/// Chats tab > Hii Owl, full screen. (This used to be a separate "Aria"
/// companion whose provider was never registered, so opening it crashed;
/// it's now the same Hii Owl as the floating button, sharing one chat.)
/// The constructor parameters are kept so existing callers still compile.
class AiCompanionChatScreen extends StatelessWidget {
  static String routeName = './AiCompanionChatScreen';

  final String personaName;
  final String personaImage;
  final String personaId;

  const AiCompanionChatScreen({
    super.key,
    this.personaName = 'Hii Owl',
    this.personaImage = AppImage.placeHolder2Icon,
    this.personaId = 'default',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OwlChatView(
        fullScreen: true,
        onClose: () => Navigator.maybePop(context),
      ),
    );
  }
}
