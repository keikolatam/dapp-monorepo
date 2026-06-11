import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/infrastructure/nim_chat_client.dart';

void main() {
  group('deltaFromSseLine', () {
    test('extrae el content delta de una línea data:', () {
      const line =
          'data: {"choices":[{"delta":{"content":"Hola"},"index":0}]}';
      expect(deltaFromSseLine(line), 'Hola');
    });

    test('ignora [DONE], comentarios y líneas vacías', () {
      expect(deltaFromSseLine('data: [DONE]'), isNull);
      expect(deltaFromSseLine(': keep-alive'), isNull);
      expect(deltaFromSseLine(''), isNull);
      expect(deltaFromSseLine('event: message'), isNull);
    });

    test('ignora JSON malformado sin lanzar', () {
      expect(deltaFromSseLine('data: {esto no es json'), isNull);
    });

    test('ignora deltas sin content (solo reasoning o rol)', () {
      expect(
        deltaFromSseLine('data: {"choices":[{"delta":{"role":"assistant"}}]}'),
        isNull,
      );
      expect(
        deltaFromSseLine(
          'data: {"choices":[{"delta":{"reasoning_content":"pensando"}}]}',
        ),
        isNull,
      );
      expect(deltaFromSseLine('data: {"choices":[]}'), isNull);
    });
  });

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
}
