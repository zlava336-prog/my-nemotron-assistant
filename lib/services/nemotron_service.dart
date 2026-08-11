import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class NemotronService {
  static const String _baseUrl = 'https://integrate.api.nvidia.com/v1';
  static const String _model = 'nvidia/nemotron-3-ultra-550b-a55b';
  
  String _apiKey = '';
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize(String apiKey) async {
    _apiKey = apiKey;
    _isInitialized = _apiKey.isNotEmpty;
  }

  Future<String> sendMessage(List<ChatMessage> messages) async {
    if (!_isInitialized || _apiKey.isEmpty) {
      throw Exception('Nemotron API not initialized. Please set your API key.');
    }

    final url = Uri.parse('$_baseUrl/chat/completions');
    
    final systemPrompt = '''You are My Nemotron Assistant, a helpful, friendly, and intelligent AI assistant. 
You can understand and respond in both English and Hindi. 
Keep your responses concise, helpful, and conversational.
If the user speaks in Hindi, reply in Hindi. If in English, reply in English.''';

    final requestMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages.map((msg) => {
        'role': msg.type == MessageType.user ? 'user' : 'assistant',
        'content': msg.content,
      }),
    ];

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': requestMessages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.9,
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null && content.isNotEmpty) {
          return content.trim();
        }
        throw Exception('Empty response from Nemotron API');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Nemotron API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception('API Error: ${error['error']?['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> sendMessageStream(List<ChatMessage> messages, Function(String) onChunk) async {
    if (!_isInitialized || _apiKey.isEmpty) {
      throw Exception('Nemotron API not initialized. Please set your API key.');
    }

    final url = Uri.parse('$_baseUrl/chat/completions');
    
    final systemPrompt = '''You are My Nemotron Assistant, a helpful, friendly, and intelligent AI assistant. 
You can understand and respond in both English and Hindi. 
Keep your responses concise, helpful, and conversational.
If the user speaks in Hindi, reply in Hindi. If in English, reply in English.''';

    final requestMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages.map((msg) => {
        'role': msg.type == MessageType.user ? 'user' : 'assistant',
        'content': msg.content,
      }),
    ];

    try {
      final request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'text/event-stream',
        })
        ..body = jsonEncode({
          'model': _model,
          'messages': requestMessages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.9,
          'stream': true,
        });

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      
      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception('API Error: ${streamedResponse.statusCode} - $errorBody');
      }

      String fullResponse = '';
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data);
            final content = json['choices']?[0]?['delta']?['content'];
            if (content != null) {
              fullResponse += content;
              onChunk(fullResponse);
            }
          } catch (e) {
  print('STREAM JSON ERROR: $e');
}
        }
      }
      
      return fullResponse;
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }
}
