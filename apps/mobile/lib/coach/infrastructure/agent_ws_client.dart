/// Infrastructure — WebSocket client for the agentic-core gateway (ADR-0003).
///
/// The Flutter app NEVER talks to the LLM directly: it speaks the agentic-core
/// WS protocol (`create_session` / `message` / `stream_token` / `stream_end`,
/// same contract as agentic-core's own `ui/lib/services/ws_client.dart`) and
/// the gateway holds the NVIDIA key server-side. Endpoint comes from
/// `--dart-define=KEIKO_AGENT_WS=ws://localhost:8080/ws` (with
/// `adb reverse tcp:8080 tcp:8080` for a USB device).
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Removes Nemotron reasoning traces (`<think>...</think>`) from [text].
/// An unclosed `<think>` swallows the rest of the string — reasoning that
/// never closed must not leak into the rendered chat.
String stripThinking(String text) {
  final closed = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '');
  final open = closed.indexOf('<think>');
  return (open >= 0 ? closed.substring(0, open) : closed).trim();
}

class AgentWsClient {
  AgentWsClient({
    required this.wsUrl,
    this.personaId = 'keiko-coach',
    this.connectTimeout = const Duration(seconds: 10),
  });

  final String wsUrl;
  final String personaId;
  final Duration connectTimeout;

  WebSocketChannel? _channel;
  Stream<Map<String, dynamic>>? _messages;
  StreamSubscription<Map<String, dynamic>>? _drain;
  String? _sessionId;

  bool get isConnected => _sessionId != null;

  /// Opens the socket and creates the chat session on the gateway.
  Future<void> connect() async {
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    final messages = channel.stream
        .map((data) => jsonDecode(data as String) as Map<String, dynamic>)
        .asBroadcastStream();
    // Permanent listener: a failed connect emits its error through the
    // channel's stream too, and with no listener that surfaces as an
    // unhandled async error. Swallow it here — callers already see the
    // failure via `ready`.
    _drain = messages.listen((_) {}, onError: (_) {});
    _channel = channel;
    _messages = messages;
    await channel.ready.timeout(connectTimeout);

    channel.sink.add(jsonEncode({
      'type': 'create_session',
      'persona_id': personaId,
      'user_id': 'keiko-app',
    }));
    final created = await messages
        .firstWhere((m) => m['type'] == 'session_created')
        .timeout(connectTimeout);
    _sessionId = created['session_id'] as String;
  }

  /// Sends one chat turn and yields the gateway's tokens until `stream_end`.
  Stream<String> streamTurn(String content) async* {
    final channel = _channel;
    final messages = _messages;
    final sessionId = _sessionId;
    if (channel == null || messages == null || sessionId == null) {
      throw StateError('AgentWsClient.streamTurn: llamá connect() primero.');
    }
    channel.sink.add(jsonEncode({
      'type': 'message',
      'session_id': sessionId,
      'persona_id': personaId,
      'content': content,
    }));
    await for (final msg in messages) {
      switch (msg['type']) {
        case 'stream_token':
          final token = msg['token'] as String? ?? '';
          if (token.isNotEmpty) yield token;
        case 'stream_end':
          return;
        case 'error':
          throw StateError(
            'Gateway error: ${msg['message'] ?? msg['code'] ?? 'desconocido'}',
          );
      }
    }
    // Socket closed mid-turn.
    throw StateError('El gateway cerró la conexión durante el turno.');
  }

  void dispose() {
    _drain?.cancel();
    _drain = null;
    _channel?.sink.close();
    _channel = null;
    _messages = null;
    _sessionId = null;
  }
}
