import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';
import '../../../utils/app_text_styles.dart';
import 'CText.dart';

class CountdownTimer extends StatefulWidget {
  CountdownTimer(
      {super.key, required this.secondsRemaining, required this.done});

  int secondsRemaining;
  final Function done;

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (widget.secondsRemaining > 0) {
          widget.secondsRemaining--;
        } else {
          widget.done();
          // Stop the timer when it reaches 0
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool timeEnd() {
    if (widget.secondsRemaining == 0) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        cText(
            text: context.translate('login.diNotGetCode') +
                formatTime(widget.secondsRemaining),
            style: AppTextStyle.mediumBlack14,
            pBottom: 3),
        TextButton(
          onPressed: () {
            if (timeEnd()) {
              widget.done();
            }
          },
          child: Text(context.translate('login.getNewCode'),
              style: AppTextStyle.mediumPrimary14),
        ),
      ],
    );
  }
}
