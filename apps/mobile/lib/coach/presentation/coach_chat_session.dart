/// Presentation — chat session bridging the agentic-core gateway and GenUI.
///
/// [CoachChatSession] implements genui's [Transport]: a [Conversation] wires
/// it to the [SurfaceController]. Each turn streams tokens from the gateway
/// (agentic-core → NIM/nemotron, per ADR-0003), strips Nemotron reasoning
/// traces, and feeds the FULL response to a per-turn [A2uiTransportAdapter]
/// — A2UI JSON becomes surfaces, and anything that does NOT parse as valid
/// A2UI (plain prose, malformed JSON, transport errors) falls back to a
/// synthetic surface with a markdown `Text` component, so the chat never
/// breaks on bad model output.
///
/// The gateway's WS proxy is stateless per turn (system + one human message),
/// so the session compensates client-side: the candidate context plus the
/// recent turn history travel inside the content of every request.
library;

import 'dart:async';

import 'package:genui/genui.dart';

import '../infrastructure/agent_ws_client.dart';

/// Streams the gateway's tokens for one turn's content.
/// Injectable so tests can run without a gateway
/// (production wiring: [AgentWsClient.streamTurn]).
typedef AgentTurnFn = Stream<String> Function(String content);

/// One past exchange kept client-side for the stateless gateway.
class _Turn {
  const _Turn(this.user, this.assistant);
  final String user;
  final String assistant;
}

class CoachChatSession implements Transport {
  CoachChatSession({
    required AgentTurnFn streamTurn,
    required String candidateContext,
    this.catalogId = 'keiko-coach',
    this.maxHistoryTurns = 6,
  })  : _streamTurn = streamTurn,
        _candidateContext = candidateContext;

  final AgentTurnFn _streamTurn;
  final String _candidateContext;
  final String catalogId;
  final int maxHistoryTurns;

  final _turns = <_Turn>[];
  final _messagesOut = StreamController<A2uiMessage>.broadcast();
  final _textOut = StreamController<String>.broadcast();
  var _turn = 0;

  @override
  Stream<A2uiMessage> get incomingMessages => _messagesOut.stream;

  /// Always silent: non-A2UI output is rendered as a fallback surface
  /// (see [sendRequest]) instead of flowing as loose chat text.
  @override
  Stream<String> get incomingText => _textOut.stream;

  /// Packs candidate context + recent history + the new message into the
  /// single content string the stateless WS proxy forwards to the model.
  String buildTurnContent(String userText) {
    final buffer = StringBuffer()
      ..writeln('CONTEXTO DEL CANDIDATO:')
      ..writeln(_candidateContext);
    if (_turns.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('HISTORIAL RECIENTE:');
      for (final t in _turns.skip(
        _turns.length > maxHistoryTurns ? _turns.length - maxHistoryTurns : 0,
      )) {
        buffer
          ..writeln('Usuario: ${t.user}')
          ..writeln('Coach: ${t.assistant}');
      }
    }
    buffer
      ..writeln()
      ..writeln('MENSAJE ACTUAL DEL USUARIO:')
      ..write(userText);
    return buffer.toString();
  }

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
      final raw = StringBuffer();
      await for (final token in _streamTurn(buildTurnContent(message.text))) {
        raw.write(token);
      }
      final full = stripThinking(raw.toString());
      if (full.isEmpty) {
        emitFallback('El modelo devolvió una respuesta vacía. Probá de nuevo.');
      } else {
        _turns.add(_Turn(message.text, full));
        adapter.addChunk(full);
      }
      // flush() closes the input so the parser drains its buffer (a
      // truncated JSON block degrades to text via incomingText). Not
      // awaited: the broadcast `done` never lands under fake-async test
      // zones; the deliveries themselves are microtasks, drained below.
      unawaited(adapter.flush());
    } catch (e) {
      emitFallback('No pude contactar al gateway del Coach: $e');
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
