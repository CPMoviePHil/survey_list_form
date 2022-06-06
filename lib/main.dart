import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(Container());
}

enum QuestionType {multipleChoice, essay, trueOrFalse}

typedef SurveyItemOnSelected = void Function(String);
typedef SurveyFormSubmit = void Function(Map<String, String>);

class SurveyItemModel {
  final String id;
  final String question;
  final List<String>? options;
  final QuestionType type;

  const SurveyItemModel({
    required this.id,
    required this.question,
    required this.options,
    this.type = QuestionType.multipleChoice
  });
}

class SurveyListForm extends StatefulWidget {

  const SurveyListForm({
    Key? key,
    required this.items,
    this.titleVisible = true,
    this.indexVisible = true,
    this.questionStyle,
    this.selectedOptionStyle,
    this.selectedOptionColor,
    this.unselectedOptionStyle,
    this.unselectedColor,
    this.onSubmit
  }) : super(key: key);

  final List<SurveyItemModel> items;
  final bool titleVisible;
  final bool indexVisible;
  final TextStyle? questionStyle;
  final TextStyle? selectedOptionStyle;
  final Color? selectedOptionColor;
  final TextStyle? unselectedOptionStyle;
  final Color? unselectedColor;
  final SurveyFormSubmit? onSubmit;

  @override
  State<SurveyListForm> createState() => _SurveyListFormState();
}

class _SurveyListFormState extends State<SurveyListForm> {

  final EdgeInsets horizontalPadding = const EdgeInsets.symmetric(horizontal: 22);
  final EdgeInsets titlePadding = const EdgeInsets.symmetric(horizontal: 22, vertical: 20);

  List<SurveyItemController> controllers = <SurveyItemController>[];
  List<StreamSubscription<Map<String, String?>>> streams = <StreamSubscription<Map<String, String?>>>[];
  Map<String, String?> userAnswers = <String, String?>{};

  @override
  void initState() {
    super.initState();
    userAnswers = { for (var e in widget.items.map((e) => e.id).toList()) e : null };
  }

  @override
  void dispose() {
    streams.map((e) => e.cancel()).toList();
    controllers.map((e) => e.close()).toList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomForm(
      items: widget.items.asMap().map((key, value) {
        final SurveyItemController controller = SurveyItemController(id: value.id);
        streams.add(controller.stream.listen((event) {
          userAnswers[event["id"]!] = userAnswers[event["answer"]!];
        }));
        controllers.add(controller);
        return MapEntry(
          key,
          SurveyItem(
            index: key + 1,
            surveyItemModel: value,
            controller: controller,
            horizontalPadding: horizontalPadding,
            questionStyle: widget.questionStyle,
          ),
        );
      },).values.toList(),
    );
  }
}

class CustomForm extends StatefulWidget {

  const CustomForm({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<SurveyItem> items;

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items.map((e) {
        return e;
      },).toList(),
    );
  }
}

class SurveyItem extends StatefulWidget {

  const SurveyItem ({
    Key? key,
    required this.index,
    required this.surveyItemModel,
    required this.controller,
    required this.horizontalPadding,
    this.questionStyle,
    this.selectedOptionStyle,
    this.selectedOptionColor,
    this.unselectedOptionStyle,
    this.unselectedColor,
  }) : super(key: key);

  final int index;
  final SurveyItemModel surveyItemModel;
  final SurveyItemController controller;
  final EdgeInsets horizontalPadding;
  final TextStyle? questionStyle;
  final TextStyle? selectedOptionStyle;
  final Color? selectedOptionColor;
  final TextStyle? unselectedOptionStyle;
  final Color? unselectedColor;

  @override
  State<SurveyItem> createState() => _SurveyItemState();
}

class _SurveyItemState extends State<SurveyItem> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.horizontalPadding,
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${widget.index}. ",
                      style: widget.questionStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.surveyItemModel.question,
                      style: widget.questionStyle,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0,),
          if (widget.surveyItemModel.type == QuestionType.multipleChoice)
            SurveyItemOptions(
              options: widget.surveyItemModel.options!,
              onSelected: widget.controller.userInput,
            ),
        ],
      ),
    );
  }
}

class SurveyItemOptions extends StatefulWidget {

  const SurveyItemOptions({
    Key? key,
    required this.options,
    this.onSelected,
    this.selectedOptionStyle,
    this.selectedOptionColor,
    this.unselectedOptionStyle,
    this.unselectedColor,
  }) : super(key: key);

  final List<String> options;
  final SurveyItemOnSelected? onSelected;
  final TextStyle? selectedOptionStyle;
  final Color? selectedOptionColor;
  final TextStyle? unselectedOptionStyle;
  final Color? unselectedColor;

  @override
  State<SurveyItemOptions> createState() => _SurveyItemOptionsState();
}

class _SurveyItemOptionsState extends State<SurveyItemOptions> {

  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.options.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: widget.onSelected != null ? () {
            widget.onSelected!(widget.options[index]);
            setState(() {
              selectedOption = widget.options[index];
            });
          } : null,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: selectedOption == widget.options[index]
                  ? widget.selectedOptionColor!
                  : widget.unselectedColor!,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedOption == widget.options[index]
                    ? widget.selectedOptionColor!
                    : widget.unselectedColor!,
              ),
            ),
            child: Text(
              widget.options[index],
              style: selectedOption == widget.options[index]
                  ? widget.selectedOptionStyle
                  : widget.unselectedOptionStyle,
            ),
          ),
        );
      },
    );
  }
}

class SurveyItemController {

  SurveyItemController({required String id}) : _id = id;
  final StreamController<Map<String, String?>> _controller = StreamController<Map<String, String?>>.broadcast();
  final String _id;

  Stream<Map<String, String?>> get stream => _controller.stream;

  void userInput (String answer) {
    _controller.add({
      "id": _id,
      "answer": answer,
    });
  }

  void close () {
    _controller.close();
  }
}

