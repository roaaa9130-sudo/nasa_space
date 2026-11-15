import 'package:flutter/material.dart';
import '../services/audio_synth_service.dart';

/// Standard Glowing Sci-Fi Glassmorphism Back Button for NASA Space Exploration UI
class SciFiBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Color? color;
  final bool isAr;

  const SciFiBackButton({
    super.key,
    this.onPressed,
    this.label,
    this.color,
    this.isAr = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF38BDF8);
    final effectiveLabel = label ?? (isAr ? 'رجوع' : 'BACK');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioSynthService.playButtonClick();
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xE0071324),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.75),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              const BoxShadow(color: Colors.black87, blurRadius: 6),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
                color: effectiveColor,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                effectiveLabel,
                style: TextStyle(
                  color: effectiveColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
