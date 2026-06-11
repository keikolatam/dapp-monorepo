/// Presentation — chat with the Coach through the agentic-core gateway
/// (ADR-0003), rendered as GenUI.
///
/// The user types in a Material 3 input ([KeikoChatInputBar]); the gateway
/// forwards to NIM/nemotron and the answer composes widgets from the Keiko
/// catalog through the A2UI protocol. The app holds NO LLM credentials — the
/// endpoint defaults to `ws://localhost:8080/ws` (override with
/// `--dart-define=KEIKO_AGENT_WS=...`; on a USB device run
/// `adb reverse tcp:8080 tcp:8080`). If the gateway is unreachable the page
/// shows a retryable "Gateway no disponible" state and the input stays
/// disabled.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:keiko_ui/keiko_ui.dart';

import '../application/coach_repository.dart';
import '../infrastructure/agent_ws_client.dart';
import 'coach_catalog.dart';
import 'coach_chat_prompt.dart';
import 'coach_chat_session.dart';

class CoachChatPage extends StatefulWidget {
  const CoachChatPage({
    super.key,
    this.repository = const CoachRepository(),
    this.wsUrl = const String.fromEnvironment(
      'KEIKO_AGENT_WS',
      defaultValue: 'ws://localhost:8080/ws',
    ),
    this.streamTurn,
  });

  final CoachRepository repository;

  /// agentic-core gateway endpoint; `--dart-define=KEIKO_AGENT_WS` overrides
  /// the localhost default. Availability is purely connectivity-based: if the
  /// gateway is unreachable the page shows a retryable error state.
  final String wsUrl;

  /// Test seam: overrides the gateway client (no socket needed).
  final AgentTurnFn? streamTurn;

  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

/// One row of the conversation: a user bubble or a GenUI surface.
class _ChatEntry {
  _ChatEntry.user(this.userText) : surfaceId = null;
  _ChatEntry.surface(this.surfaceId) : userText = null;

  final String? userText;
  final String? surfaceId;
}

class _CoachChatPageState extends State<CoachChatPage> {
  final Catalog _catalog = buildCoachCatalog();
  late final SurfaceController _controller =
      SurfaceController(catalogs: [_catalog]);
  final _scrollController = ScrollController();
  final _entries = <_ChatEntry>[];

  AgentWsClient? _client;
  CoachChatSession? _session;
  Conversation? _conversation;
  bool _isWaiting = false;
  bool _connecting = false;
  Object? _initError;

  bool get _ready => _conversation != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _connecting = true;
      _initError = null;
    });
    try {
      final plan = await widget.repository.loadDemoPlan();
      final candidateContext = serializeCoachContext(plan);

      var streamTurn = widget.streamTurn;
      if (streamTurn == null) {
        final client = AgentWsClient(wsUrl: widget.wsUrl);
        try {
          await client.connect();
        } catch (_) {
          // Close the half-open channel so a failed connect leaks nothing.
          client.dispose();
          rethrow;
        }
        _client = client;
        streamTurn = client.streamTurn;
      }
      final session = CoachChatSession(
        streamTurn: streamTurn,
        candidateContext: candidateContext,
      );
      final conversation =
          Conversation(controller: _controller, transport: session);
      conversation.events.listen(_onConversationEvent);
      if (!mounted) {
        conversation.dispose();
        session.dispose();
        return;
      }
      setState(() {
        _session = session;
        _conversation = conversation;
        _connecting = false;
      });
    } catch (e) {
      _client?.dispose();
      _client = null;
      if (mounted) {
        setState(() {
          _initError = e;
          _connecting = false;
        });
      }
    }
  }

  void _onConversationEvent(ConversationEvent event) {
    if (!mounted) return;
    switch (event) {
      case ConversationSurfaceAdded(:final surfaceId):
        setState(() => _entries.add(_ChatEntry.surface(surfaceId)));
        _scrollToBottom();
      case ConversationComponentsUpdated():
        setState(() {});
        _scrollToBottom();
      case ConversationSurfaceRemoved(:final surfaceId):
        setState(
          () => _entries.removeWhere((e) => e.surfaceId == surfaceId),
        );
      case ConversationContentReceived():
      case ConversationWaiting():
      case ConversationError():
        // Waiting/errors are handled around _send; loose text never flows
        // (the session renders it as a fallback surface).
        break;
    }
  }

  Future<void> _send(String text) async {
    final conversation = _conversation;
    if (conversation == null || _isWaiting) return;
    setState(() {
      _entries.add(_ChatEntry.user(text));
      _isWaiting = true;
    });
    _scrollToBottom();
    try {
      await conversation.sendRequest(ChatMessage.user(text));
    } finally {
      if (mounted) setState(() => _isWaiting = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _conversation?.dispose();
    _session?.dispose();
    _client?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach · Chat (Nemotron)')),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          KeikoChatInputBar(
            enabled: _ready,
            isLoading: _isWaiting,
            hintText: 'Preguntale al Coach...',
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_initError != null) {
      return _ConnectionErrorState(error: _initError!, onRetry: _init);
    }
    if (_connecting || !_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty && !_isWaiting) {
      return _EmptyConversationState();
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length + (_isWaiting ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _entries.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final entry = _entries[index];
        if (entry.userText != null) return _UserBubble(text: entry.userText!);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Surface(
            surfaceContext: _controller.contextFor(entry.surfaceId!),
            defaultBuilder: (_) => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _EmptyConversationState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            'Preguntale al Coach por tus brechas,\nroadmap o interview prep.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'agentic-core + Nemotron componen la respuesta como UI (A2UI).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ConnectionErrorState extends StatelessWidget {
  const _ConnectionErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Gateway no disponible', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '¿Está corriendo agentic-core?\n'
              'apps/coach-sidecar/run-local.sh\n'
              '(device USB: adb reverse tcp:8080 tcp:8080;\n'
              'otro endpoint: --dart-define=KEIKO_AGENT_WS=...)\n\n$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

