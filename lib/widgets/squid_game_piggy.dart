import 'dart:math';
import 'package:flutter/material.dart';

class SquidGamePiggyCard extends StatefulWidget {
  final double totalSavings;
  final double totalTarget;
  final Function(double) onQuickDeposit;

  const SquidGamePiggyCard({
    super.key,
    required this.totalSavings,
    required this.totalTarget,
    required this.onQuickDeposit,
  });

  @override
  State<SquidGamePiggyCard> createState() => SquidGamePiggyCardState();
}

class SquidGamePiggyCardState extends State<SquidGamePiggyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _coinController;
  final List<_FallingCoin> _fallingCoins = [];
  String? _lastDepositText;

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  // Trigger Squid Game style Coin Drop Animation
  void triggerCoinDrop(double amount) {
    _fallingCoins.clear();
    final random = Random();
    for (int i = 0; i < 8; i++) {
      _fallingCoins.add(
        _FallingCoin(
          startX: random.nextDouble() * 200 - 100, // horizontal spread
          delay: i * 0.08,
          scale: 0.8 + random.nextDouble() * 0.5,
        ),
      );
    }

    _lastDepositText = '+฿${amount.toStringAsFixed(0)} 🪙';
    _coinController.forward(from: 0.0);
    widget.onQuickDeposit(amount);
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = (widget.totalTarget > 0)
        ? (widget.totalSavings / widget.totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1055), Color(0xFF7597DE)], // Squid Game Night Sky / Glowing Piggy theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7597DE).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Label & Crown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD166), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'กระปุกหมูทองคำ Squid Game 🐷🪙',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Squid Savings',
                  style: TextStyle(
                    color: Color(0xFF2B1055),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Glass Piggy Bank Center Display with Coin Drop Animation
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glowing Piggy Bank Glass Container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD166).withOpacity(0.35),
                        const Color(0xFFFFD166).withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFD166).withOpacity(0.6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.savings_rounded,
                          size: 64,
                          color: Color(0xFFFFD166),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(overallProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Falling Coins Animation Layer
                if (_coinController.isAnimating)
                  ..._fallingCoins.map((coin) {
                    final progress = (_coinController.value - coin.delay).clamp(0.0, 1.0);
                    final double dropY = -60 + (progress * 110); // From top drop into piggy
                    final double opacity = (1.0 - progress * 0.4).clamp(0.0, 1.0);

                    return Positioned(
                      top: dropY,
                      left: 120 + coin.startX * (1 - progress * 0.3),
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: coin.scale,
                          child: const Text('🪙', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                    );
                  }),

                // Floating Deposit Text Popup (+฿500 🪙)
                if (_coinController.isAnimating && _lastDepositText != null)
                  Positioned(
                    top: 10 - (_coinController.value * 30),
                    child: Opacity(
                      opacity: (1.0 - _coinController.value).clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          _lastDepositText!,
                          style: const TextStyle(
                            color: Color(0xFF2B1055),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total Savings Balance
          Text(
            '฿${widget.totalSavings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'เป้าหมายรวม ฿${widget.totalTarget.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Quick 1-Tap Coin Drop Deposit Buttons
          const Text(
            'กดปุ่มเพื่อหยอดเหรียญลงกระปุก 🪙✨',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCoinDropBtn(50),
              const SizedBox(width: 8),
              _buildCoinDropBtn(100),
              const SizedBox(width: 8),
              _buildCoinDropBtn(500),
              const SizedBox(width: 8),
              _buildCoinDropBtn(1000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinDropBtn(double amount) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => triggerCoinDrop(amount),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD166),
          foregroundColor: const Color(0xFF2B1055),
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          '+฿${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _FallingCoin {
  final double startX;
  final double delay;
  final double scale;

  _FallingCoin({
    required this.startX,
    required this.delay,
    required this.scale,
  });
}
