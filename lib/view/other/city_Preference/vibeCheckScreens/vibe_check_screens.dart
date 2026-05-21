import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/stay_connected_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../../controller/vibe_check/vibe_check_controller.dart';
import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class VibeCheckScreen extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;
  final String? selectedEvents;
  final String? customEvent;
  final String? selectedVibes;
  final String? sexuality;
  final String? interestedIn;
  final String? pronouns;
  final List<Map<String, String>>? selectedMediaList;
  static String routeName = './VibeCheckScreen';

  const VibeCheckScreen(
      {super.key,
      this.selectedGenres,
      this.customGenre,
      this.selectedEvents,
      this.customEvent,
      this.selectedVibes,
      this.sexuality,
      this.interestedIn,
      this.pronouns,
      this.selectedMediaList});

  @override
  State<VibeCheckScreen> createState() => _VibeCheckScreenState();
}

class _VibeCheckScreenState extends State<VibeCheckScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> progressImages = [
    AppImage.frequencyOneicon,
    AppImage.frequencyTwoicon,
    AppImage.frequencyIncrementlast,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVibeCheckData();
    });
  }

  void _fetchVibeCheckData() {
    final vibeCheckProvider =
        Provider.of<VibeCheckController>(context, listen: false);
    vibeCheckProvider.fetchVibeCheckData(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final vibeCheckProvider =
        Provider.of<VibeCheckController>(context, listen: false);

    if (currentPage < 2) {
      setState(() {
        currentPage++;
      });
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On last page, prepare data and navigate
      _submitAndNavigate();
    }
  }

  void _submitAndNavigate() {
    final vibeCheckProvider =
        Provider.of<VibeCheckController>(context, listen: false);

    // Get formatted answers
    List<Map<String, String>> formattedAnswers =
        vibeCheckProvider.getFormattedAnswers();

    // Print for debugging
    print("Formatted Answers for API: $formattedAnswers");

    // Navigate to next screen
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: StayConnectedScreen(
          selectedGenres: widget.selectedGenres,
          customGenre: widget.customGenre,
          selectedEvents: widget.selectedEvents,
          customEvent: widget.customEvent,
          selectedVibes: widget.selectedVibes,
          sexuality: widget.sexuality,
          interestedIn: widget.interestedIn,
          pronouns: widget.pronouns,
          selectedMediaList: widget.selectedMediaList,
          formattedAnswers: formattedAnswers,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _skipToNext() {
    _nextPage();
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          _previousPage();
          return false;
        },
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  text: AppLanguage.continueText[language],
                  onPress: _nextPage,
                ),
                SizedBox(height: size.height * 1 / 100),
                GestureDetector(
                  onTap: _skipToNext,
                  child: Text(
                    textAlign: TextAlign.center,
                    AppLanguage.skip[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.greyLightColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context),
            ),
            child: Consumer<VibeCheckController>(
              builder: (context, vibeCheckProvider, child) {
                if (vibeCheckProvider.getIsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.pinkColor,
                    ),
                  );
                }

                List<List<dynamic>> distributedQuestions =
                    vibeCheckProvider.distributeQuestionsToPages();

                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    // App Header
                    SizedBox(
                      width: size.width * 0.9,
                      height: size.height * 0.08,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _previousPage,
                            child: SizedBox(
                              width: size.width * 0.04,
                              height: size.height * 0.05,
                              child: Image.asset(
                                AppImage.backArrowIcon,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: Center(
                              child: Text(
                                AppLanguage.vibeCheck[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.06),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // Progress Indicator
                    SizedBox(
                      width: size.width * 0.88,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${currentPage + 1}/3',
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Image.asset(
                        progressImages[currentPage],
                        width: size.width * 0.2,
                        height: size.width * 0.1,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // PageView for all three screens
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        itemCount: 3,
                        itemBuilder: (context, pageIndex) {
                          return VibeCheckPageContent(
                            key: ValueKey(pageIndex),
                            questionList:
                                distributedQuestions.length > pageIndex
                                    ? distributedQuestions[pageIndex]
                                    : [],
                            pageNumber: pageIndex + 1,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class VibeCheckPageContent extends StatefulWidget {
  final List<dynamic> questionList;
  final int pageNumber;

  const VibeCheckPageContent({
    super.key,
    required this.questionList,
    required this.pageNumber,
  });

  @override
  State<VibeCheckPageContent> createState() => _VibeCheckPageContentState();
}

class _VibeCheckPageContentState extends State<VibeCheckPageContent> {
  // Store controllers for each question
  final Map<String, TextEditingController> _controllers = {};
  // Track dropdown state for each question
  final Map<int, bool> _dropdownStates = {};

  bool _doesTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    if (text.trim().isEmpty || maxWidth <= 0) return false;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final vibeCheckProvider =
        Provider.of<VibeCheckController>(context, listen: false);

    for (int i = 0; i < widget.questionList.length; i++) {
      final question = widget.questionList[i];
      final questionId = question['_id'] ?? '';
      final savedAnswer = vibeCheckProvider.getAnswer(questionId);

      _controllers[questionId] = TextEditingController(text: savedAnswer);
      _dropdownStates[i] = false;
    }
  }

  @override
  void dispose() {
    // Just dispose controllers, saving happens in onChanged
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleDropdown(int index) {
    setState(() {
      _dropdownStates[index] = !(_dropdownStates[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final questionStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: AppFont.plusJakartaSansFamily,
    );
    final descriptionStyle = const TextStyle(
      fontSize: 13,
      fontFamily: AppFont.plusJakartaSansFamily,
      fontWeight: FontWeight.w400,
      color: Color(0xffB7AFC9),
    );

    if (widget.questionList.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: TextStyle(
            color: AppColor.secondryColor(context),
            fontSize: 16,
            fontFamily: AppFont.fontFamily,
          ),
        ),
      );
    }

    return Consumer<VibeCheckController>(
      builder: (context, vibeCheckProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.15),
            child: Column(
              children: [
                // Loop through all questions on this page
                ...List.generate(widget.questionList.length, (index) {
                  final question = widget.questionList[index];
                  final questionId = question['_id'] ?? '';
                  final controller = _controllers[questionId];
                  final isDropdownOpen = _dropdownStates[index] ?? false;

                  return Column(
                    children: [
                      // Question Dropdown
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isAnswered =
                              vibeCheckProvider.isQuestionAnswered(questionId);
                          final double trailingWidth = isAnswered ? 60 : 28;
                          final double availableTextWidth =
                              constraints.maxWidth - 36 - trailingWidth;
                          final String questionText =
                              (question['question'] ?? 'Question').toString();
                          final String descriptionText =
                              (question['description'] ?? 'Description')
                                  .toString();

                          final bool showArrow = _doesTextOverflow(
                                text: questionText,
                                style: questionStyle,
                                maxWidth: availableTextWidth,
                              ) ||
                              _doesTextOverflow(
                                text: descriptionText,
                                style: descriptionStyle,
                                maxWidth: availableTextWidth,
                              );

                          return GestureDetector(
                            onTap:
                                showArrow ? () => _toggleDropdown(index) : null,
                            child: Container(
                              width: size.width * 0.9,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.themeColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          questionText,
                                          style: questionStyle,
                                          maxLines: showArrow
                                              ? (isDropdownOpen ? null : 1)
                                              : null,
                                          overflow: showArrow && !isDropdownOpen
                                              ? TextOverflow.ellipsis
                                              : TextOverflow.visible,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          descriptionText,
                                          style: descriptionStyle,
                                          maxLines: showArrow
                                              ? (isDropdownOpen ? null : 1)
                                              : null,
                                          overflow: showArrow && !isDropdownOpen
                                              ? TextOverflow.ellipsis
                                              : TextOverflow.visible,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAnswered) ...[
                                    const SizedBox(width: 10),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                  if (showArrow) ...[
                                    const SizedBox(width: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: AnimatedRotation(
                                        turns: isDropdownOpen ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: size.height * 0.015),

                      // Answer Input Field
                      Container(
                        width: size.width * 90 / 100,
                        height: size.height * 6 / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColor.filledcolor(context),
                          border: Border.all(
                            color: AppColor.pinkColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                              blurRadius: 0,
                              color: AppColor.transparentColor.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: controller,
                          cursorColor: AppColor.secondryColor(context),
                          style:
                              TextStyle(color: AppColor.secondryColor(context)),
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) {
                            vibeCheckProvider.saveAnswer(questionId, value);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: size.width * 4 / 100,
                                right: size.width * 2 / 100,
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: size.width * 2 / 100,
                              minHeight: size.height * 6 / 100,
                            ),
                            hintText: AppLanguage.myperfectNight[language],
                            hintStyle:
                                AppConstant.textFilledStyle1(context).copyWith(
                              color: AppColor.hintPlaceHolderText,
                            ),
                            contentPadding: EdgeInsets.only(
                              right: size.width * 4 / 100,
                            ),
                          ),
                        ),
                      ),

                      // Add spacing between questions
                      if (index < widget.questionList.length - 1)
                        SizedBox(height: size.height * 0.025),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
