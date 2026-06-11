import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:keiko_app/coach/presentation/coach_catalog.dart';
import 'package:keiko_app/coach/presentation/coach_chat_session.dart';

/// Harness: a session wired to a real [SurfaceController] through a real
/// [Conversation], with the gateway stream mocked.
class _Harness {
  _Harness(AgentTurnFn streamTurn) {
    controller = SurfaceController(catalogs: [buildCoachCatalog()]);
    session = CoachChatSession(
      streamTurn: streamTurn,
      candidateContext: '{"candidateName": "Andrés"}',
    );
    conversation = Conversation(controller: controller, transport: session);
    sub = controller.surfaceUpdates.listen((update) {
      if (update is SurfaceAdded) surfaces[update.surfaceId] = update.definition;
      if (update is ComponentsUpdated) {
        surfaces[update.surfaceId] = update.definition;
      }
    });
  }

  late final SurfaceController controller;
  late final CoachChatSession session;
  late final Conversation conversation;
  late final StreamSubscription<SurfaceUpdate> sub;

  /// Latest definition per surface.
  final surfaces = <String, SurfaceDefinition>{};

  Future<void> send(String text) async {
    await conversation.sendRequest(ChatMessage.user(text));
    await pumpEventQueue();
  }

  String? rootTextOf(String surfaceId) =>
      surfaces[surfaceId]?.components['root']?.properties['text'] as String?;

  void dispose() {
    sub.cancel();
    conversation.dispose();
    session.dispose();
    controller.dispose();
  }
}

AgentTurnFn _emitting(List<String> tokens) =>
    (_) => Stream.fromIterable(tokens);

void main() {
  test('una respuesta A2UI válida se vuelve surface en el controller',
      () async {
    final h = _Harness(_emitting([
      'Acá va tu UI:\n',
      '```json\n{"version":"v0.9","createSurface":'
          '{"surfaceId":"model-1","catalogId":"keiko-coach"}}\n```\n',
      '```json\n{"version":"v0.9","updateComponents":{"surfaceId":"model-1",'
          '"components":[{"id":"root","component":"Text",'
          '"text":"Tu brecha principal es Kubernetes."}]}}\n```',
    ]));

    await h.send('¿cuál es mi brecha principal?');

    expect(h.surfaces, contains('model-1'));
    expect(h.rootTextOf('model-1'), 'Tu brecha principal es Kubernetes.');
    // La prosa alrededor del JSON cae al surface de texto del turno.
    expect(h.rootTextOf('chat-text-1'), contains('Acá va tu UI'));
    h.dispose();
  });

  test('JSON malformado degrada a surface de texto — el chat no se rompe',
      () async {
    final h = _Harness(_emitting([
      'Esto vino roto: ```json\n{"version":"v0.9","createSurface":{{{\n``` fin.',
    ]));

    await h.send('hola');

    // Nada que no sea A2UI válido crea surfaces del modelo...
    expect(h.surfaces.keys, ['chat-text-1']);
    // ...pero el contenido completo queda legible como texto.
    expect(h.rootTextOf('chat-text-1'), contains('Esto vino roto'));
    h.dispose();
  });

  test('JSON truncado (sin cierre) se vacía como texto al cerrar el turno',
      () async {
    final h = _Harness(_emitting([
      'La UI: {"version":"v0.9","createSurface":{"surfaceId":"x"',
    ]));

    await h.send('hola');

    expect(h.surfaces.keys, ['chat-text-1']);
    expect(h.rootTextOf('chat-text-1'), contains('createSurface'));
    h.dispose();
  });

  test('error del gateway cae al fallback con mensaje, sin lanzar', () async {
    final h = _Harness((_) => Stream.error(Exception('gateway caído')));

    await h.send('hola');

    expect(h.rootTextOf('chat-text-1'),
        contains('No pude contactar al gateway'));
    h.dispose();
  });

  test(
      'el content del turno lleva contexto del candidato, historial reciente '
      'y stripea el thinking', () async {
    final contents = <String>[];
    final h = _Harness((content) {
      contents.add(content);
      return Stream.value('<think>pensando mucho</think>Respuesta final.');
    });

    await h.send('hola');
    await h.send('seguimos');

    // Primer turno: contexto + mensaje, sin historial.
    expect(contents[0], contains('CONTEXTO DEL CANDIDATO'));
    expect(contents[0], contains('"candidateName": "Andrés"'));
    expect(contents[0], contains('MENSAJE ACTUAL DEL USUARIO:\nhola'));
    expect(contents[0], isNot(contains('HISTORIAL RECIENTE')));
    // Segundo turno: historial con el thinking ya stripeado.
    expect(contents[1], contains('HISTORIAL RECIENTE'));
    expect(contents[1], contains('Usuario: hola'));
    expect(contents[1], contains('Coach: Respuesta final.'));
    expect(contents[1], isNot(contains('pensando')));
    h.dispose();
  });

  test('turnos sucesivos crean surfaces de texto independientes', () async {
    var call = 0;
    final h = _Harness((_) {
      call++;
      return Stream.value('Respuesta $call');
    });

    await h.send('uno');
    await h.send('dos');

    expect(h.rootTextOf('chat-text-1'), 'Respuesta 1');
    expect(h.rootTextOf('chat-text-2'), 'Respuesta 2');
    h.dispose();
  });
}
