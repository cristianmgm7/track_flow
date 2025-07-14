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
    return Row(
      children: [
        // Botón de agregar
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white70,
              size: 24,
            ),
            onPressed: () {
              // Acción del botón de agregar
            },
          ),
        ),
        
        // Campo de texto expandible
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: 'Ask anything',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
              maxLines: null, // Permite múltiples líneas
              textInputAction: TextInputAction.newline,
            ),
          ),
        ),
        
        // Botón de micrófono
        Container(
          margin: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(
              Icons.mic,
              color: Colors.white70,
              size: 24,
            ),
            onPressed: () {
              // Acción del micrófono
            },
          ),
        ),
        
        // Botón de waveform/audio
        Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.graphic_eq,
              color: Colors.black,
              size: 20,
            ),
            onPressed: _handleSend,
          ),
        ),
      ],
    );
  }
}
