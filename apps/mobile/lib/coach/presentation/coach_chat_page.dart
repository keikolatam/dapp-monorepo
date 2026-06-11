/// Presentation — chat with the Coach (Nemotron 3 Ultra via NVIDIA NIM),
/// rendered as GenUI.
///
/// The user types in a Material 3 input ([KeikoChatInputBar]); the model
/// answers by composing widgets from the Keiko catalog through the A2UI
/// protocol. Without an API key (`--dart-define=NVIDIA_API_KEY=...`) the
/// page shows an empty state and the input stays disabled.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:keiko_ui/keiko_ui.dart';

import '../application/coach_repository.dart';
import '../infrastructure/nim_chat_client.dart';
import 'coach_catalog.dart';
import 'coach_chat_prompt.dart';
import 'coach_chat_session.dart';

class CoachChatPage extends StatefulWidget {
  const CoachChatPage({
    super.key,
    this.repository = const CoachRepository(),
    this.apiKey = const String.fromEnvironment('NVIDIA_API_KEY'),
    this.streamCompletion,
  });

  final CoachRepository repository;

  /// NIM API key. Empty (no `--dart-define`) disables the chat.
  final String apiKey;

  /// Test seam: overrides the NIM client (no network, no key needed).
  final NimStreamFn? streamCompletion;

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

  CoachChatSession? _session;
  Conversation? _conversation;
  bool _isWaiting = false;
  Object? _initError;

  bool get _hasBackend =>
      widget.streamCompletion != null || widget.apiKey.isNotEmpty;
  bool get _ready => _conversation != null;

  @override
  void initState() {
    super.initState();
    if (_hasBackend) _init();
  }

  Future<void> _init() async {
    try {
      final plan = await widget.repository.loadDemoPlan();
      final systemPrompt =
          buildCoachChatSystemPrompt(plan: plan, catalog: _catalog);
      final stream = widget.streamCompletion ??
          NimChatClient(apiKey: widget.apiKey).streamChat;
      final session = CoachChatSession(
        streamCompletion: stream,
        systemPrompt: systemPrompt,
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
      });
    } catch (e) {
      if (mounted) setState(() => _initError = e);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach · Chat (Nemotron)')),
      body: Column(
        children: [
          Expanded(child: !_hasBackend ? _MissingKeyState() : _buildBody()),
          KeikoChatInputBar(
            enabled: _hasBackend && _ready,
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
      return Center(child: Text('Error al iniciar el chat: $_initError'));
    }
    if (!_ready) {
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
            'Nemotron 3 Ultra compone la respuesta como UI (A2UI).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MissingKeyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.key_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Configurá NVIDIA_API_KEY', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Corré la app con\n'
              'flutter run --dart-define=NVIDIA_API_KEY=...\n'
              'para chatear con el Coach.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
