import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/nemotron_service.dart';

class ChatProvider extends ChangeNotifier {
  final NemotronService _nemotronService = NemotronService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  String _apiKey = '';
  bool _isStreaming = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('nemotron_api_key') ?? '';
    if (_apiKey.isNotEmpty) {
      await _nemotronService.initialize(_apiKey);
    }
    _loadMessages();
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('chat_messages') ?? [];
    _messages.clear();
    _messages.addAll(messagesJson.map((json) => ChatMessage.fromJson(
      Map<String, dynamic>.from(jsonDecode(json) as Map)
    )));
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chat_messages', _messages.map((m) => jsonEncode(m.toJson())).toList());
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nemotron_api_key', _apiKey);
    await _nemotronService.initialize(_apiKey);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (!_nemotronService.isInitialized) {
      _error = 'Please set your Nemotron API key in settings';
      notifyListeners();
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    _isStreaming = true;
    notifyListeners();

    try {
      final assistantMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: '',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();

      await _nemotronService.sendMessageStream(
        _messages.where((m) => m.type != MessageType.system).toList(),
        (partialResponse) {
          _messages[_messages.length - 1] = assistantMessage.copyWith(content: partialResponse);
          notifyListeners();
        },
      );

      await _saveMessages();
    } catch (e) {
      _messages.removeWhere((m) => m.id == userMessage.id);
      _error = e.toString();
      if (_messages.isNotEmpty && _messages.last.type == MessageType.assistant && _messages.last.content.isEmpty) {
        _messages.removeLast();
      }
    } finally {
      _isLoading = false;
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    await _saveMessages();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}