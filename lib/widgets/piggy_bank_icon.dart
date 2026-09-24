import 'package:flutter/material.dart';

class PiggyBankDecoration extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color badgeColor;
  final String? badgeText;

  const PiggyBankDecoration({
    super.key,
    this.size = 120,
    this.primaryColor = const Color(0xFFFF6B8B),
    this.badgeColor = const Color(0xFFFFD166),
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow circle
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: primaryColor.withOpacity(0.25),
                width: 3,
              ),
            ),
          ),
          // Cute Piggy Bank Icon & Coin
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                size: size * 0.22,
                color: badgeColor,
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.savings_rounded,
                size: size * 0.44,
                color: primaryColor,
              ),
            ],
          ),
          // Sparkle Star
          Positioned(
            top: size * 0.16,
            right: size * 0.14,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: badgeColor,
            ),
          ),
          // Badge Label
          if (badgeText != null)
            Positioned(
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
