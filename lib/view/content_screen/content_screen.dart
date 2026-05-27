import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../provider/darkmode_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';

class ContentClass {
  final String header;
  final String contenttype;
  ContentClass({required this.header, required this.contenttype});
}

class Content extends StatelessWidget {
  static String routeName = './Content';
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    ContentClass? object;
    object = ModalRoute.of(context)!.settings.arguments as ContentClass;
    return Scaffold(
      body: ContentScreen(
        header: object.header,
        contenttype: object.contenttype,
      ),
    );
  }
}

class ContentScreen extends StatefulWidget {
  final String header;
  final String contenttype;

  const ContentScreen(
      {super.key, required this.header, required this.contenttype});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen>
    with SingleTickerProviderStateMixin {
  bool isApiCalling = false;
  late WebViewController _webViewController;
  late final WebViewController _controller;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    log("++++++++++++++++++++++++${widget.contenttype}");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() { isApiCalling = true; });
          },
          onPageFinished: (String url) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) setState(() { isApiCalling = false; });
            });
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : \$progress%)");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.contenttype));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
              backgroundColor: AppColor.primaryColor(context),
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
              ))),
      body: SafeArea(
          bottom: false,
          child: Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.black,
            child: Column(
              children: [
                AppHeader(
                  text: widget.header,
                  onPress: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      height: screenHeight,
                      width: screenWidth * 0.95,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          // WebView - Hidden initially
                          AnimatedOpacity(
                            opacity: isApiCalling ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: WebViewWidget(
                              controller: _controller,
                            ),
                          ),

                          // Loading Overlay - Responsive Design
                          if (isApiCalling)
                            Container(
                              color: AppColor.secondryColor(context),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.08,
                                      height: screenWidth * 0.08,
                                      child: RotationTransition(
                                        turns: _animationController,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColor.primaryColor(context),
                                          ),
                                          strokeWidth: 2.5,
                                          backgroundColor:
                                              Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          )),
    );
  }
}
