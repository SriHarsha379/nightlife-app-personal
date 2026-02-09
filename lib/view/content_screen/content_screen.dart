import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
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
    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
              backgroundColor: AppColor.primaryColor(context),
              systemOverlayStyle:  SystemUiOverlayStyle(
                  systemNavigationBarColor: AppColor.primaryColor(context),
                  systemNavigationBarIconBrightness: Brightness.light,
                  statusBarColor: AppColor.primaryColor(context),
                  statusBarIconBrightness: Brightness.light))),
      body: SafeArea(
          child: Container(
        height: screenHeight,
        width: screenWidth,
        color: AppColor.primaryColor(context),
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
                        child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child:  Text(
                      "This Mobile Application End User Terms and agreement between us.and is a your use of the APP on the MOBILE PLATFORMS and MOBILE DEVICES.  will be used you. YOU ACKN-OWLEDGE THAT YOU HAVE READ AND UNDERSTAND THIS Terms and conditions and Privacy Policy; ou REPRESENT THAT YOU ARE OF LEGAL AGE TO ENTER INTO A BINDING AGREEMENT AND ACCEPT THIS AGREEMENT AND AGREE THAT YOU ARE LEGALLY BOUND BY ITS TERMS AND CONDI-TIONS and PRIVACY POLICY. IF YOU DO NOTAGREE TO THESE TERMS AND CONDITION and PRIVACY POLICY, DO NOT DOWNLOAD/INSTALL/USE THE APPLICATION AND DELETE IT FROM YOUR MOBILE DEVICE. License Grant. Subject to the terms of this Agreement, We grant you a limited,non- exclusive, ndon-transferable license to download, install and use the Application for your personal, non-commercial use on a mobile device owned or otherwise ontrolled by you ('Mobile Device') strictly in accordance with the Application's documentation access ,stream, download and use on such Mobile Device the Content and Services made available in or herwise accessible through the Application, strictly in accordance with this Agreement and the Terms of Use applicable to such Content and Services as set forth in. License Restrictions.Licensee shall not: copy the Application, except as expressly permitted by this license; modify, translate, adapt or otherwise create derivative works or ements, whether or not patentable, of the Application; reverse engineer disassemble, decompile, decode or otherwise attempt to derive or gain access to the source code of the Application or any part thereof; remove, delete,alter or obscure any trademarks or any copyright, trademark, patent or other intellectual propertyor proprietary rights notices from the Application, including any copy thereof; rent, lease, lend, sell, sublicense, assign, distribute, publish, transfer or otherwise make available the Application or any features or functionality of the appl-  cation, to any third party for any reason, including by making the Application available on a network where it is capable of being accessed by more than one device at any time; remove, disable, circumvent or otherwise create or implement any workaround to any copy protection, rights management or security features in or protecting the Application; or use the Application in, or in association with, the design, construction, maintenance or operation of any hazardous environments or systems, including any power generation systems; aircraft navigation or communication systems, air traffic control systems or any other transport management systems; safety-critical applications, including medical or life-support systems, vehicle operation applications or any police, fire or other safety response systems; and military or aerospace applications, weapons systems or environments. Reservation of Rights. You acknowledge and agree that the Application is provided under license, and will be used by you. You do not acquire any interest in the Application under this Agreement, or any other rightsthereto",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont .fontFamily)),
                ),
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
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppColor.themeColor,
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
