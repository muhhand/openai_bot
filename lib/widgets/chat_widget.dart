import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/services/assets_manger.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.message, required this.chatIndex});

  final String message;
  final int chatIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatIndex == 0
                      ? AssestManger.userImage
                      : AssestManger.botImage,
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: chatIndex == 0
                        ? TextWidget(label: message)
                        : DefaultTextStyle(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            child: AnimatedTextKit(
                                repeatForever: false,
                                isRepeatingAnimation: false,
                                displayFullTextOnTap: true,
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TyperAnimatedText(message.trim())
                                ]),
                          )),
              ],
            ),
          ),
        )
      ],
    );
  }
}
