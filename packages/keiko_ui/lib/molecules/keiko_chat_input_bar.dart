import 'package:flutter/material.dart';

/// Molecule — Material 3 chat input bar with a send button.
///
/// Multiline text field (grows up to [maxFieldHeight]) plus a circular send
/// button that turns into a progress indicator while [isLoading]. Wrapped in
/// a bottom [SafeArea] so it stays clear of gesture/navigation bars on
/// edge-to-edge apps.
class KeikoChatInputBar extends StatefulWidget {
  const KeikoChatInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.isLoading = false,
    this.hintText = 'Escribe un mensaje...',
    this.maxFieldHeight = 120,
  });

  /// Called with the trimmed text when the user submits a non-empty message.
  final ValueChanged<String> onSend;

  /// Whether the field and button accept input at all.
  final bool enabled;

  /// Shows a spinner in the send button and blocks submission.
  final bool isLoading;

  final String hintText;
  final double maxFieldHeight;

  @override
  State<KeikoChatInputBar> createState() => _KeikoChatInputBarState();
}

class _KeikoChatInputBarState extends State<KeikoChatInputBar> {
  final _controller = TextEditingController();

  bool get _canSend => widget.enabled && !widget.isLoading;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_canSend) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxFieldHeight),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    filled: true,
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _canSend ? _send : null,
              tooltip: 'Enviar',
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
