import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controller/vibe_check/vibe_check_controller.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/profile_completion_navigation.dart';
import '../../utilities/vibe_answer_rules.dart';

/// Answers Vibe Check questions after signup — the onboarding version
/// (vibeCheckScreens/vibe_check_screens.dart) is coupled to the rest of
/// the signup flow (forwards into StayConnectedScreen), so this is a
/// simpler standalone version for members who skipped it the first time.
class EditVibeCheckScreen extends StatefulWidget {
  // Set when reached via the profile-completion prompt/reminder, so a
  // successful save can chain to whatever's next.
  final bool cameFromCompletionPrompt;
  const EditVibeCheckScreen({
    super.key,
    this.cameFromCompletionPrompt = false,
  });

  @override
  State<EditVibeCheckScreen> createState() => _EditVibeCheckScreenState();
}

class _EditVibeCheckScreenState extends State<EditVibeCheckScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VibeCheckController>(context, listen: false)
          .fetchVibeCheckData(context);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String questionId, String initial) {
    return _controllers.putIfAbsent(
      questionId,
          () => TextEditingController(text: initial),
    );
  }

  Future<void> _save() async {
    final vibeCheckProvider =
    Provider.of<VibeCheckController>(context, listen: false);
    final allAnswers = vibeCheckProvider.getFormattedAnswers();

    // Same rule as signup: $kVibeMinWords+ real words per answer.
    if (allAnswers.any((a) => isUnfinishedVibeAnswer(a['answer'] ?? ''))) {
      SnackBarToastMessage.info(
        context,
        "Answers need at least $kVibeMinWords words - finish your answer or clear the box.",
      );
      return;
    }
    final formattedAnswers =
        allAnswers.where((a) => isValidVibeAnswer(a['answer'] ?? '')).toList();

    if (formattedAnswers.isEmpty) {
      SnackBarToastMessage.info(
        context,
        "Answer at least one question in $kVibeMinWords+ words to save.",
      );
      return;
    }

    setState(() => _isSaving = true);

    final res = await Provider.of<PostApiProvider>(context, listen: false)
        .updateVibeChecksApi(context, formattedAnswers);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res == null) return;

    if (widget.cameFromCompletionPrompt) {
      await continueToNextMissingProfileField(
        context,
        cameFromCompletionPrompt: true,
        justCompletedField: 'vibe_check',
      );
      return;
    }

    if (mounted) Navigator.pop(context);
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
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: "Vibe Check",
              ),
              Expanded(
                child: Consumer<VibeCheckController>(
                  builder: (context, vibeCheckProvider, child) {
                    if (vibeCheckProvider.getIsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.pinkColor,
                        ),
                      );
                    }

                    final questions = vibeCheckProvider.getVibeCheckList;
                    if (questions.isEmpty) {
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              "A few of these help other members get a sense of you — answer as many as you like.",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 13,
                                color: AppColor.filledText(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(questions.length, (index) {
                            final question = questions[index];
                            final questionId =
                            (question['_id'] ?? '').toString();
                            final questionText =
                            (question['question'] ?? 'Question')
                                .toString();
                            final descriptionText =
                            (question['description'] ?? '').toString();
                            final controller = _controllerFor(
                              questionId,
                              vibeCheckProvider.getAnswer(questionId),
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    questionText,
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                  if (descriptionText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      descriptionText,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 13,
                                        color: AppColor.filledText(context),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColor.filledcolor(context),
                                      border: Border.all(
                                        color: AppColor.pinkColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: controller,
                                      cursorColor:
                                      AppColor.secondryColor(context),
                                      style: TextStyle(
                                          color:
                                          AppColor.secondryColor(context)),
                                      maxLines: 2,
                                      minLines: 1,
                                      onChanged: (value) {
                                        vibeCheckProvider.saveAnswer(
                                            questionId, value);
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                        AppLanguage.myperfectNight[language],
                                        hintStyle: AppConstant
                                            .textFilledStyle1(context)
                                            .copyWith(
                                          color: AppColor.hintPlaceHolderText,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  VibeWordCounter(controller: controller),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: size.height * 0.14),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _isSaving
              ? const CircularProgressIndicator(color: AppColor.pinkColor)
              : AppButton(
            text: AppLanguage.continueText[language],
            onPress: _save,
          ),
        ),
      ),
    );
  }
}