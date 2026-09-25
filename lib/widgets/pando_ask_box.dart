import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/properties.dart';
import '../theme/app_theme.dart';
import 'pando_provider.dart';

/// Small input near Pando (Section 1.7). Submitting a question never opens
/// a chat thread — the answer replaces the sticky note text and is spoken.
class PandoAskBox extends StatefulWidget {
  final double width;
  const PandoAskBox({super.key, this.width = 220});

  @override
  State<PandoAskBox> createState() => _PandoAskBoxState();
}

class _PandoAskBoxState extends State<PandoAskBox> {
  final _controller = TextEditingController();

  void _submit([String? text]) {
    final value = (text ?? _controller.text).trim();
    if (value.isEmpty) return;
    _controller.clear();
    context.read<PandoProvider>().ask(value, mockProperties);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _submit,
                style: AppText.sans(size: 12),
                decoration: InputDecoration(
                  hintText: 'Ask Pando…',
                  hintStyle: AppText.sans(size: 12, color: AppColors.muted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const Icon(Icons.mic_none_rounded, color: AppColors.muted, size: 16),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _submit(),
              child: const CircleAvatar(radius: 14, backgroundColor: AppColors.red, child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
