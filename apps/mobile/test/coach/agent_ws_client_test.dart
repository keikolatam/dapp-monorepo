import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/infrastructure/agent_ws_client.dart';

void main() {
  group('stripThinking', () {
    test('elimina bloques <think> cerrados', () {
      expect(
        stripThinking('<think>razonando...</think>Hola, ¿cómo estás?'),
        'Hola, ¿cómo estás?',
      );
    });

    test('descarta un <think> sin cierre hasta el final', () {
      expect(stripThinking('Respuesta.<think>razonando sin cerrar'),
          'Respuesta.');
    });

    test('no toca texto sin razonamiento', () {
      expect(stripThinking('```json\n{"a":1}\n```'), '```json\n{"a":1}\n```');
    });
  });

  test('streamTurn sin connect lanza StateError claro', () {
    final client = AgentWsClient(wsUrl: 'ws://localhost:9');
    expect(
      () => client.streamTurn('hola').first,
      throwsA(isA<StateError>()),
    );
  });
}
