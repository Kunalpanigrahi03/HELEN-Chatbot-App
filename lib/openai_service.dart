import 'dart:convert';

import 'package:allen/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.'
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An Internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assitant',
          'content': content,
        });
        return content;
      }
      return 'An Internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({
          'role': 'assitant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An Internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }
}
