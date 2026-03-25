import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/controller/blocked_users/blocked_users_controller.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/utilities/app_header.dart';
import 'package:provider/provider.dart';

class BlockUserScreen extends StatefulWidget {
  static String routeName = './BlockUserScreen';
  const BlockUserScreen({super.key});
  @override
  State<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BlockedUsersController>().fetchBlockedUsers(context);
    });
  }

  String _str(dynamic value) => value?.toString().trim() ?? '';

  ImageProvider _avatarProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/icons/ProfilePhoto.png');
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return NetworkImage('${AppConfigProvider.imageUrl}$path');
  }

  Future<bool?> _showUnblockConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.washpressColor,
          title: Text(
            'Unblock User',
            style: TextStyle(
              color: AppColor.secondryColor(dialogContext),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to unblock this user?',
            style: TextStyle(
              color: AppColor.secondryColor(dialogContext),
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColor.textcolor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Unblock',
                style: TextStyle(
                  color: AppColor.buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 100 / 100,
              width: MediaQuery.of(context).size.width * 100 / 100,
              color: AppColor.primaryColor(context),
              child: Column(children: [
                AppHeader(
                    text: "Blocked Users",
                    onPress: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                Expanded(
                  child: Consumer<BlockedUsersController>(
                    builder: (context, blockedController, _) {
                      final blockedUsers = blockedController.blockedUsers;
                      return Column(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          if (blockedController.isLoading)
                            const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.buttonColor,
                                ),
                              ),
                            )
                          else if (blockedController.blockedUsers.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                ),
                                const Text(
                                  'No user found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.buttonColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: blockedUsers.length,
                                itemBuilder: (context, index) {
                                  final item = blockedUsers[index];
                                  final blockedUser =
                                      item['blocked_user'] is Map
                                          ? Map<String, dynamic>.from(
                                              item['blocked_user'] as Map)
                                          : <String, dynamic>{};
                                  final userId = _str(blockedUser['_id']);
                                  final firstName =
                                      _str(blockedUser['first_name']);
                                  final lastName =
                                      _str(blockedUser['last_name']);
                                  final fullName = _str(blockedUser['name']);
                                  final userName =
                                      _str(blockedUser['username']);
                                  final profileImage =
                                      _str(blockedUser['profile_image']);
                                  final displayName = fullName.isNotEmpty
                                      ? fullName
                                      : ('$firstName $lastName').trim();
                                  final isUnblocking =
                                      blockedController.isUnblocking(userId);

                                  return Column(
                                    children: [
                                      Container(
                                        width: size.width * 90 / 100,
                                        height: size.height * 8.5 / 100,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                            height: size.height * 10 / 100,
                                            width: size.width * 13 / 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: _avatarProvider(
                                                    profileImage),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            displayName.isEmpty
                                                ? 'Unknown User'
                                                : displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          subtitle: Text(
                                            userName.isEmpty
                                                ? '@unknown'
                                                : '@$userName',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.secondryColor(
                                                    context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: GestureDetector(
                                            onTap:
                                                isUnblocking || userId.isEmpty
                                                    ? null
                                                    : () async {
                                                        final shouldUnblock =
                                                            await _showUnblockConfirmDialog();
                                                        if (shouldUnblock !=
                                                            true) {
                                                          return;
                                                        }
                                                        await blockedController
                                                            .unblockUser(
                                                          context,
                                                          targetUserId: userId,
                                                        );
                                                      },
                                            child: Text(
                                              isUnblocking
                                                  ? 'Unblocking...'
                                                  : 'Unblock',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.buttonColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.1 / 100),
                                    ],
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),
                        ],
                      );
                    },
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
