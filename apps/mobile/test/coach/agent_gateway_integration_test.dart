/// Integración REAL contra el gateway agentic-core local (WS → NIM/nemotron).
///
/// Excluido del run default: se salta si no hay gateway escuchando en
/// KEIKO_AGENT_WS (default ws://localhost:8080/ws). Correr con el gateway
/// arriba (`apps/coach-sidecar/run-local.sh` con NVIDIA_API_KEY en su env):
///
///   flutter test test/coach/agent_gateway_integration_test.dart
@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/infrastructure/agent_ws_client.dart';

Future<bool> _gatewayUp(String host, int port) async {
  try {
    final socket = await Socket.connect(host, port,
        timeout: const Duration(seconds: 2));
    socket.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

void main() async {
  final wsUrl = Platform.environment['KEIKO_AGENT_WS'] ??
      'ws://localhost:8080/ws';
  final uri = Uri.parse(wsUrl);
  final up = await _gatewayUp(uri.host, uri.port);

  test(
    'turno corto contra el gateway entrega al menos un token y stream_end',
    () async {
      final client = AgentWsClient(wsUrl: wsUrl);
      await client.connect();
      expect(client.isConnected, isTrue);

      final tokens = <String>[];
      await for (final t
          in client.streamTurn('Respondé solo la palabra "hola".')) {
        tokens.add(t);
      }
      client.dispose();
      // No se imprime contenido: solo se verifica el protocolo completo.
      expect(tokens, isNotEmpty,
          reason: 'el gateway debe entregar al menos un stream_token');
      // El WS proxy degrada errores del LLM a stream_token: un error
      // empaquetado no debe contar como respuesta del modelo.
      expect(tokens.join(), isNot(contains('Error connecting')),
          reason: 'la respuesta debe venir del modelo, no de un error LLM');
    },
    skip: up ? false : 'Requiere el gateway agentic-core corriendo en $wsUrl',
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
