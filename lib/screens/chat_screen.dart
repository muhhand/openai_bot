import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/providers/chats_provider.dart';
import 'package:chatgpt_app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/models_provider.dart';
import '../services/assets_manger.dart';
import '../widgets/chat_widget.dart';
import '../widgets/text_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late FocusNode focusNode;
  late ScrollController listscrollController;
  var isListening = false;
  SpeechToText speechToText = SpeechToText();

  List<ChatModel> chatList = [];

  @override
  void initState() {
    listscrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    listscrollController.dispose();
    focusNode.dispose();
    textEditingController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await Services.showModalSheet(context);
              },
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ))
        ],
        elevation: 2,
        title: Text('Open Ai Bot'),
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 14, right: 0),
          child: Image.asset(AssestManger.openaiLogo),
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Flexible(
            child: ListView.builder(
                controller: listscrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    message: chatProvider.getChatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex,
                  );
                }),
          ),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          SizedBox(
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AvatarGlow(
                  repeatPauseDuration: Duration(milliseconds: 100),
                  animate: isListening,
                  duration: Duration(milliseconds: 2000),
                  glowColor: Colors.white,
                  showTwoGlows: true,
                  endRadius: 45,
                  child: GestureDetector(
                    onTapDown: (details) async {
                      if (!isListening) {
                        var available = await speechToText.initialize();
                        if (available) {
                          setState(() {
                            isListening = true;
                            speechToText.listen(onResult: (result) {
                              setState(() {
                                textEditingController.text =
                                    result.recognizedWords;
                              });
                            });
                          });
                        }
                      }
                    },
                    onTapUp: ((details) {
                      setState(() {
                        isListening = false;
                      });
                      speechToText.stop();
                    }),
                    child: CircleAvatar(
                      radius: 35,
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                      backgroundColor: cardColor,
                    ),
                  ),
                ),
              ),
              Material(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        focusNode: focusNode,
                        style: TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessage(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: InputDecoration.collapsed(
                            hintText: 'How can I help you ?',
                            hintStyle: TextStyle(color: Colors.grey)),
                      )),
                      IconButton(
                          onPressed: () async {
                            await sendMessage(
                                modelsProvider: modelsProvider,
                                chatProvider: chatProvider);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }

  Future<void> sendMessage(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(label: 'You Cannot write multiple message'),
        backgroundColor: Colors.red,
      ));
    }

    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(label: 'Please Write Something'),
        backgroundColor: Colors.red,
      ));
    }
    try {
      String messg = textEditingController.text;
      setState(() {
        _isTyping = true;
        //chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(message: messg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageBot(
          message: messg, modelId: modelsProvider.getCurrentModel);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(label: e.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollToEnd();
        _isTyping = false;
      });
    }
  }

  void scrollToEnd() {
    listscrollController.animateTo(
        listscrollController.position.maxScrollExtent,
        duration: Duration(seconds: 2),
        curve: Curves.easeOut);
  }
}
