import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../services/api_services.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String message}) {
    chatList.add(ChatModel(msg: message, chatIndex: 1));
    notifyListeners();
  }

  Future<void> sendMessageBot(
      {required String message, required String modelId}) async {
    chatList.addAll(
        await ApiService.sendMessage(message: message, modelId: modelId));
    notifyListeners();
  }
}
