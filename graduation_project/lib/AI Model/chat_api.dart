// File: lib/chat_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';   // <-- Add this
import 'package:http/http.dart' as http;

class ChatApi {
  static const _apiKey = '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';
  static const _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> getBotResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": userMessage},
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        debugPrint('OpenRouter error: ${response.statusCode} ${response.body}');
        return "Sorry, I couldn't get a response from the AI.";
      }
    } catch (e) {
      debugPrint('API exception: $e');
      return "Something went wrong. Please try again.";
    }
  }
}
