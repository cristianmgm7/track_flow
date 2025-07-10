import 'package:flutter/material.dart';

class AudioCommentInputComment extends StatefulWidget {
  final void Function(String) onSend;
  final FocusNode? focusNode;
  const AudioCommentInputComment({super.key, required this.onSend, this.focusNode});

  @override
  State<AudioCommentInputComment> createState() =>
      _AudioCommentInputCommentState();
}

class _AudioCommentInputCommentState extends State<AudioCommentInputComment> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      widget.focusNode?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Escribe un comentario...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
