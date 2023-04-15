import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chatgpt_app/constants/api_constant.dart';
import 'package:chatgpt_app/models/ModelsModel.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/models'),
          headers: {"Authorization": "Bearer $OPENAI_API_KEY"});
      Map jsonRespose = jsonDecode(response.body);
      if (jsonRespose['error'] != null) {
        //print('${jsonRespose['error']['message']}');
        throw HttpException(jsonRespose['error']['message']);
      }
      List temp = [];
      for (var value in jsonRespose['data']) {
        temp.add(value);
        print('temp ${value["id"]}');
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      print('error  $error');
      rethrow;
    }
  }

  ////////////////////////////////////////////////////////////////

  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      var response = await http.post(Uri.parse('$baseUrl/completions'),
          headers: {
            "Authorization": "Bearer $OPENAI_API_KEY",
            "Content-Type": 'application/json'
          },
          body: jsonEncode(
              {'model': modelId, 'prompt': message, "max_tokens": 10}));

      Map jsonRespose = jsonDecode(response.body);

      if (jsonRespose['error'] != null) {
        //print('${jsonRespose['error']['message']}');
        throw HttpException(jsonRespose['error']['message']);
      }

      List<ChatModel> chatList = [];

      if (jsonRespose["choices"].length > 0) {
        {
          print("${jsonRespose['choices'][0]['text']}");
          chatList = List.generate(
              jsonRespose["choices"].length,
              (index) => ChatModel(
                  msg: jsonRespose['choices'][index]['text'], chatIndex: 1));
        }
      }
      return chatList;
    } catch (error) {
      print('error  $error');
      rethrow;
    }
  }
}
