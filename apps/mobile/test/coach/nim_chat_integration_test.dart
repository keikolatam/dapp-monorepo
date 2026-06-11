/// Integración REAL contra NVIDIA NIM (red + API key).
///
/// Excluido del run default: sin `NVIDIA_API_KEY` en el entorno se salta.
/// Correr con:
///   NVIDIA_API_KEY=... flutter test test/coach/nim_chat_integration_test.dart
@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/infrastructure/nim_chat_client.dart';

void main() {
  final key = Platform.environment['NVIDIA_API_KEY'] ?? '';

  test(
    'streaming corto contra nemotron entrega al menos un delta',
    () async {
      final client = NimChatClient(apiKey: key);
      final deltas = <String>[];
      await for (final d in client.streamChat(
        const [
          NimMessage.system('Respondé en una sola palabra, sin razonar.'),
          NimMessage.user('Decí "hola".'),
        ],
        maxTokens: 1024,
      )) {
        deltas.add(d);
      }
      // No se imprime contenido: solo se verifica que el stream parseó deltas.
      expect(deltas, isNotEmpty,
          reason: 'el stream SSE debe entregar al menos un content delta');
    },
    skip: key.isEmpty ? 'Requiere NVIDIA_API_KEY en el entorno' : false,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
