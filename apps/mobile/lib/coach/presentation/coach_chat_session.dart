/// Presentation — chat session bridging NVIDIA NIM and the GenUI surfaces.
///
/// [CoachChatSession] implements genui's [Transport]: a [Conversation] wires
/// it to the [SurfaceController]. Each turn streams the completion from NIM,
/// strips Nemotron reasoning traces, and feeds the FULL response to a
/// per-turn [A2uiTransportAdapter] — A2UI JSON becomes surfaces, and anything
/// that does NOT parse as valid A2UI (plain prose, malformed JSON, transport
/// errors) falls back to a synthetic surface with a markdown `Text`
/// component, so the chat never breaks on bad model output.
library;

import 'dart:async';

import 'package:genui/genui.dart';

import '../infrastructure/nim_chat_client.dart';

/// Produces the streaming completion for a conversation history.
/// Injectable so tests can run without network or API key.
typedef NimStreamFn = Stream<String> Function(List<NimMessage> history);

class CoachChatSession implements Transport {
  CoachChatSession({
    required NimStreamFn streamCompletion,
    required String systemPrompt,
    this.catalogId = 'keiko-coach',
  })  : _streamCompletion = streamCompletion,
        _history = [NimMessage.system(systemPrompt)];

  final NimStreamFn _streamCompletion;
  final String catalogId;
  final List<NimMessage> _history;

  final _messagesOut = StreamController<A2uiMessage>.broadcast();
  final _textOut = StreamController<String>.broadcast();
  var _turn = 0;

  /// Conversation history sent to NIM (system + user/assistant turns).
  List<NimMessage> get history => List.unmodifiable(_history);

  @override
  Stream<A2uiMessage> get incomingMessages => _messagesOut.stream;

  /// Always silent: non-A2UI output is rendered as a fallback surface
  /// (see [sendRequest]) instead of flowing as loose chat text.
  @override
  Stream<String> get incomingText => _textOut.stream;

  @override
  Future<void> sendRequest(ChatMessage message) async {
    _turn++;
    final turn = _turn;
    String? fallbackId;
    final fallbackText = StringBuffer();

    // Renders [text] into this turn's fallback surface (created lazily),
    // accumulating across chunks so prose around JSON blocks stays together.
    void emitFallback(String text) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;
      if (fallbackId == null) {
        fallbackId = 'chat-text-$turn';
        _messagesOut.add(
          CreateSurface(surfaceId: fallbackId!, catalogId: catalogId),
        );
      }
      if (fallbackText.isNotEmpty) fallbackText.write('\n\n');
      fallbackText.write(trimmed);
      _messagesOut.add(
        UpdateComponents(
          surfaceId: fallbackId!,
          components: [
            Component(
              id: 'root',
              type: 'Text',
              properties: {'text': fallbackText.toString()},
            ),
          ],
        ),
      );
    }

    // Per-turn adapter: closing it at end of turn drains its buffer, so a
    // truncated JSON block degrades to fallback text instead of leaking
    // into the next turn.
    final adapter = A2uiTransportAdapter();
    final msgSub = adapter.incomingMessages.listen(_messagesOut.add);
    final txtSub = adapter.incomingText.listen(
      emitFallback,
      onError: (Object e) =>
          emitFallback('No pude renderizar parte de la respuesta como UI.'),
    );
    try {
      _history.add(NimMessage.user(message.text));
      final raw = StringBuffer();
      await for (final delta in _streamCompletion(List.unmodifiable(_history))) {
        raw.write(delta);
      }
      final full = stripThinking(raw.toString());
      if (full.isEmpty) {
        emitFallback('El modelo devolvió una respuesta vacía. Probá de nuevo.');
      } else {
        _history.add(NimMessage.assistant(full));
        adapter.addChunk(full);
      }
      // flush() closes the input so the parser drains its buffer (a
      // truncated JSON block degrades to text via incomingText). Not
      // awaited: the broadcast `done` never lands under fake-async test
      // zones; the deliveries themselves are microtasks, drained below.
      unawaited(adapter.flush());
    } catch (e) {
      emitFallback('No pude contactar a Nemotron: $e');
    } finally {
      // A zero timer runs after the whole microtask cascade: every queued
      // stream delivery lands before the subscriptions are cancelled.
      // The cancel futures are not awaited — cancellation takes effect
      // synchronously and their confirmations also hang under fake-async.
      await Future<void>.delayed(Duration.zero);
      unawaited(msgSub.cancel());
      unawaited(txtSub.cancel());
      adapter.dispose();
    }
  }

  @override
  void dispose() {
    _messagesOut.close();
    _textOut.close();
  }
}
