import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_header.dart';
import '../../commonWidget/artist_image_preview.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_image.dart';

class ViewAllLinupScreen extends StatefulWidget {
  static String routeName = './ViewAllLinupScreen';
  const ViewAllLinupScreen({super.key, required this.viewAllLineUpList});
  final List<dynamic> viewAllLineUpList;
  @override
  State<ViewAllLinupScreen> createState() => _ViewAllLinupScreenState();
}

class _ViewAllLinupScreenState extends State<ViewAllLinupScreen> {
  List viewAllLineUpList = [];
  void _openLineupImagePreview(
    BuildContext context,
    String imagePath,
  ) {
    if (imagePath.trim().isEmpty) return;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: LineupArtistPreviewScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    viewAllLineUpList = widget.viewAllLineUpList;
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
                    text: "LineUp",
                    onPress: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: viewAllLineUpList.length,
                          itemBuilder: (context, index) {
                            final artistDetails = viewAllLineUpList[index];
                            return Column(
                              children: [
                                SizedBox(
                                  width: size.width * 90 / 100,
                                  height: size.height * 8.5 / 100,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: GestureDetector(
                                      onTap: () {
                                        _openLineupImagePreview(
                                          context,
                                          (artistDetails['image'] ?? "")
                                              .toString(),
                                        );
                                      },
                                      child: Container(
                                        height: size.width * 16 / 100,
                                        width: size.width * 16 / 100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${AppConfigProvider.imageUrl}${artistDetails['image']}",
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              AppImage.placeHolderIcon,
                                              fit: BoxFit.cover,
                                            ),
                                            placeholder: (context, url) =>
                                                Center(
                                              child: LoadingAnimationWidget
                                                  .dotsTriangle(
                                                color: AppColor.themeColor,
                                                size: 35,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      artistDetails['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                    subtitle: Text(
                                      artistDetails['title'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              AppColor.secondryColor(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // trailing: Text(
                                    //   viewAllLineUpList[index]['message'],
                                    //   style: const TextStyle(
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.w500,
                                    //     color: AppColor.buttonColor,
                                    //   ),
                                    // ),
                                  ),
                                ),
                                SizedBox(height: size.height * 2 / 100),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
