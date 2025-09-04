// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:chatbot/constant/api_constant.dart';
import 'package:http/http.dart' as http;

class GooglleApiService {
  static String apiKey = ApiConstant.apiKey;
  static String baseUrl = ApiConstant.baseUrl;

  static Future<String> getApiResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$apiKey"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("candidates") && data["candidates"].isNotEmpty) {
          var firstCandidate = data["candidates"][0];

          if (firstCandidate.containsKey("content") &&
              firstCandidate["content"].containsKey("parts") &&
              firstCandidate["content"]["parts"].isNotEmpty) {
            return firstCandidate["content"]["parts"][0]["text"] ??
                "AI response was empty.";
          }
        }
        return "AI did not return any content.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print("Error=> $e");
      return "Error: $e";
    }
  }

  // New: Vision API call with image file and optional prompt
  static Future<String> getVisionResponse(
      {required File imageFile,
      String? prompt,
      String mimeType = 'image/jpeg'}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Data = base64Encode(bytes);

      final body = {
        "contents": [
          {
            "parts": [
              if (prompt != null && prompt.trim().isNotEmpty) {"text": prompt},
              {
                "inline_data": {"mime_type": mimeType, "data": base64Data}
              }
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse("$baseUrl$apiKey"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("candidates") && data["candidates"].isNotEmpty) {
          var firstCandidate = data["candidates"][0];
          if (firstCandidate.containsKey("content") &&
              firstCandidate["content"].containsKey("parts") &&
              firstCandidate["content"]["parts"].isNotEmpty) {
            return firstCandidate["content"]["parts"][0]["text"] ??
                "AI response was empty.";
          }
        }
        return "AI did not return any content.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print('Vision API error: $e');
      return "Error: $e";
    }
  }

  // New: Image generation placeholder. Replace with Gemini Imagen endpoint later.
  // Returns bytes of a generated image for a given prompt.
  static Future<List<int>> generateImageBytes(String prompt,
      {int width = 1024, int height = 1024}) async {
    try {
      // Placeholder: fetch a deterministic image from picsum using the prompt as seed
      final seed =
          Uri.encodeComponent(prompt.trim().isEmpty ? 'prompt' : prompt);
      final url = Uri.parse('https://picsum.photos/seed/$seed/$width/$height');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        return resp.bodyBytes;
      }
      throw Exception('Image generation failed: ${resp.statusCode}');
    } catch (e) {
      print('Image generation error: $e');
      rethrow;
    }
  }
}
