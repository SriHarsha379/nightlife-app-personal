import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/stay_connected_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class VibeCheckScreen extends StatefulWidget {
  static String routeName = './VibeCheckScreen';

  const VibeCheckScreen({super.key});

  @override
  State<VibeCheckScreen> createState() => _VibeCheckScreenState();
}

class _VibeCheckScreenState extends State<VibeCheckScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Define questions for each page separately
  final List<List<Map<String, String>>> allQuestionsData = [
    // Page 1 questions
    [
      {
        "title": "What's your perfect night out?",
        "subtitle": "Describe your ideal evening in a few words.",
      },
      {
        "title": "Go–to drink?",
        "subtitle": "What do you usually order at the bar?",
      },
      {
        "title": "Something interesting about you?",
        "subtitle": "Tell something interesting about yourself",
      },
    ],
    // Page 2 questions
    [
      {
        "title": "What's your vibe?",
        "subtitle": "How would you describe your energy?",
      },
      {
        "title": "Favorite music genre?",
        "subtitle": "What gets you moving?",
      },
      {
        "title": "Ideal crowd size?",
        "subtitle": "Intimate gathering or big party?",
      },
    ],
    // Page 3 questions
    [
      {
        "title": "What time do you usually go out?",
        "subtitle": "Are you an early bird or night owl?",
      },
      {
        "title": "Dress code preference?",
        "subtitle": "Casual or dressed up?",
      },
      {
        "title": "Must-have at a venue?",
        "subtitle": "What makes a place perfect for you?",
      },
    ],
  ];

  final List<String> progressImages = [
    AppImage.frequencyOneicon,
    AppImage.frequencyTwoicon, // Update with actual image path
    AppImage.frequencyIncrementlast, // Update with actual image path
  ];

  // Store answers for each page
  final Map<int, Map<int, String>> pageAnswers = {
    0: {},
    1: {},
    2: {},
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
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
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const StayConnectedScreen(), // Always starts at index 0
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
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

  void _saveAnswer(int questionIndex, String answer) {
    setState(() {
      pageAnswers[currentPage]![questionIndex] = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.statusbar,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
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
                    style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.greyLightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: AppColor.backgroundGradientcolor,
            ),
            child: Column(
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
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Center(
                          child: Text(
                            AppLanguage.vibeCheck[language],
                            style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ),
                      // Spacer to balance the layout
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
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
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
                    itemBuilder: (context, index) {
                      return VibeCheckPageContent(
                        key: ValueKey(index),
                        questionList: allQuestionsData[index],
                        pageNumber: index + 1,
                        currentPage: index,
                        savedAnswers: pageAnswers[index] ?? {},
                        onAnswerSaved: (questionIndex, answer) {
                          _saveAnswer(questionIndex, answer);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VibeCheckPageContent extends StatefulWidget {
  final List<Map<String, String>> questionList;
  final int pageNumber;
  final int currentPage;
  final Map<int, String> savedAnswers;
  final Function(int, String) onAnswerSaved;

  const VibeCheckPageContent({
    super.key,
    required this.questionList,
    required this.pageNumber,
    required this.currentPage,
    required this.savedAnswers,
    required this.onAnswerSaved,
  });

  @override
  State<VibeCheckPageContent> createState() => _VibeCheckPageContentState();
}

class _VibeCheckPageContentState extends State<VibeCheckPageContent> {
  bool isDropdownOpen = false;
  int selectedQuestionIndex = 0;
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the default selected question to the first one
    selectedQuestionIndex = 0;
    // Load saved answer if exists
    _loadSavedAnswer();
  }

  void _loadSavedAnswer() {
    if (widget.savedAnswers.containsKey(selectedQuestionIndex)) {
      answerController.text = widget.savedAnswers[selectedQuestionIndex]!;
    }
  }

  @override
  void dispose() {
    // Save the current answer before disposing
    if (answerController.text.isNotEmpty) {
      widget.onAnswerSaved(selectedQuestionIndex, answerController.text);
    }
    answerController.dispose();
    super.dispose();
  }

  void _onQuestionChanged(int index) {
    // Save current answer before switching
    if (answerController.text.isNotEmpty) {
      widget.onAnswerSaved(selectedQuestionIndex, answerController.text);
    }

    setState(() {
      selectedQuestionIndex = index;
      isDropdownOpen = false;

      // Load the saved answer for the new question
      if (widget.savedAnswers.containsKey(index)) {
        answerController.text = widget.savedAnswers[index]!;
      } else {
        answerController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.15),
        child: Column(
          children: [
            // Dropdown Question Selector
            GestureDetector(
              onTap: () {
                setState(() {
                  isDropdownOpen = !isDropdownOpen;
                });
              },
              child: Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(50),
                    topRight: const Radius.circular(50),
                    bottomLeft: Radius.circular(isDropdownOpen ? 0 : 50),
                    bottomRight: Radius.circular(isDropdownOpen ? 0 : 50),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.questionList[selectedQuestionIndex]
                                ["title"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFont.plusJakartaSansFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.questionList[selectedQuestionIndex]
                                ["subtitle"]!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: AppFont.plusJakartaSansFamily,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffB7AFC9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isDropdownOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dropdown List
            if (isDropdownOpen)
              const Divider(
                height: 0.2,
                thickness: 0.5,
                color: AppColor.greyLightColor,
                indent: 30,
                endIndent: 30,
              ),
            if (isDropdownOpen)
              Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 19),
                decoration: const BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.questionList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onQuestionChanged(index),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.questionList[index]["title"]!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: AppFont.plusJakartaSansFamily,
                                    ),
                                  ),
                                ),
                                // Show checkmark if this question has been answered
                                if (widget.savedAnswers.containsKey(index))
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.questionList[index]["subtitle"]!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffB7AFC9),
                                fontFamily: AppFont.plusJakartaSansFamily,
                              ),
                            ),
                            if (index < widget.questionList.length - 1)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Divider(
                                  height: 0.2,
                                  thickness: 0.5,
                                  color: AppColor.greyLightColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: size.height * 0.04),

            // Answer Input Field
            Container(
              width: size.width * 90 / 100,
              height: size.height * 6 / 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColor.filledcolor,
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
                controller: answerController,
                cursorColor: AppColor.secondryColor,
                style: const TextStyle(color: AppColor.secondryColor),
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  // Auto-save as user types
                  widget.onAnswerSaved(selectedQuestionIndex, value);
                },
                decoration: InputDecoration(
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
                  border: InputBorder.none,
                  hintText: AppLanguage.myperfectNight[language],
                  hintStyle: AppConstant.textFilledStyle1.copyWith(
                    color: AppColor.hintPlaceHolderText,
                  ),
                  contentPadding: EdgeInsets.only(
                    right: size.width * 4 / 100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
