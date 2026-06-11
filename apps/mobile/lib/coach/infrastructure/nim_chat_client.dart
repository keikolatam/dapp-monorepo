/// Infrastructure — streaming client for NVIDIA NIM (OpenAI-compatible).
///
/// Speaks SSE against `chat/completions` with `stream: true` and yields the
/// text deltas as they arrive. The API key is NEVER hardcoded: it reaches the
/// app exclusively via `--dart-define=NVIDIA_API_KEY=...` and is read with
/// [String.fromEnvironment] at the call site.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

/// One turn of the conversation sent to NIM ({role, content}).
class NimMessage {
  const NimMessage(this.role, this.content);
  const NimMessage.system(String content) : this('system', content);
  const NimMessage.user(String content) : this('user', content);
  const NimMessage.assistant(String content) : this('assistant', content);

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Extracts the content delta from a single SSE line, or null when the line
/// carries no text (comments, `[DONE]`, malformed JSON, reasoning-only
/// deltas). Pure function so the protocol parsing is unit-testable offline.
String? deltaFromSseLine(String line) {
  if (!line.startsWith('data:')) return null;
  final payload = line.substring(5).trim();
  if (payload.isEmpty || payload == '[DONE]') return null;
  try {
    final json = jsonDecode(payload);
    if (json is! Map<String, dynamic>) return null;
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final delta = (choices.first as Map<String, dynamic>)['delta'];
    if (delta is! Map<String, dynamic>) return null;
    final content = delta['content'];
    return content is String && content.isNotEmpty ? content : null;
  } on FormatException {
    return null;
  }
}

/// Removes Nemotron reasoning traces (`<think>...</think>`) from [text].
/// An unclosed `<think>` swallows the rest of the string — reasoning that
/// never closed must not leak into the rendered chat.
String stripThinking(String text) {
  final closed = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '');
  final open = closed.indexOf('<think>');
  return (open >= 0 ? closed.substring(0, open) : closed).trim();
}

class NimChatClient {
  NimChatClient({
    required this.apiKey,
    this.model = defaultModel,
    this.baseUrl = defaultBaseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  static const defaultBaseUrl = 'https://integrate.api.nvidia.com/v1';
  static const defaultModel = 'nvidia/nemotron-3-ultra-550b-a55b';

  final String apiKey;
  final String model;
  final String baseUrl;
  final Dio _dio;

  bool get hasKey => apiKey.isNotEmpty;

  /// Streams the completion for [messages], emitting content deltas.
  Stream<String> streamChat(
    List<NimMessage> messages, {
    int maxTokens = 4096,
    double temperature = 0.6,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '$baseUrl/chat/completions',
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'text/event-stream',
        },
      ),
      data: {
        'model': model,
        'messages': [for (final m in messages) m.toJson()],
        'stream': true,
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
    );

    final lines = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      final delta = deltaFromSseLine(line);
      if (delta != null) yield delta;
    }
  }
}
