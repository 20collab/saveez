import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../widgets/squid_game_piggy.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0; // 0=Home, 1=Goals, 2=Analytics, 3=Reminders, 4=Profile
  int _goalsTab = 0; // 0=Active Goals, 1=Completed Goals Archive
  int _quoteIndex = 0;

  late String _currentUserName;
  String _currentAvatarEmoji = '🐷';
  String _currentCurrency = 'THB (฿)';
  bool _isPinLockEnabled = true;
  bool _isDarkMode = false;
  String _goalSearchQuery = '';

  final GlobalKey<SquidGamePiggyCardState> _squidPiggyKey = GlobalKey();

  final List<String> _avatarEmojiOptions = ['🐷', '👑', '🦄', '🐱', '🦊', '🐻', '🦁', '💎', '🚀', '🤖'];

  final List<Map<String, dynamic>> _goalIconOptions = [
    {'icon': Icons.savings_rounded, 'name': 'หมูออมทรัพย์'},
    {'icon': Icons.phone_iphone_rounded, 'name': 'สมาร์ทโฟน'},
    {'icon': Icons.flight_takeoff_rounded, 'name': 'ท่องเที่ยว'},
    {'icon': Icons.shield_rounded, 'name': 'เงินฉุกเฉิน'},
    {'icon': Icons.headphones_rounded, 'name': 'หูฟัง/ไอที'},
    {'icon': Icons.directions_car_rounded, 'name': 'ยานพาหนะ'},
    {'icon': Icons.home_rounded, 'name': 'บ้าน/ที่อยู่อาศัย'},
    {'icon': Icons.laptop_mac_rounded, 'name': 'คอมพิวเตอร์'},
    {'icon': Icons.shopping_bag_rounded, 'name': 'ช้อปปิ้ง'},
  ];

  final List<Color> _goalColorOptions = [
    const Color(0xFFFF6B8B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFD166),
    const Color(0xFF1DD1A1),
    const Color(0xFF54A0FF),
    const Color(0xFF5f27cd),
  ];

  final List<String> _dailyQuotes = [
    '💡 "การออมเงินเล็กๆ ในวันนี้ คืออิสรภาพทางการเงินในวันข้างหน้า!"',
    '🌟 "วินัยสร้างได้ตั้งแต่วันนี้ ยอดเงินออมเติบโตอย่างมั่นคง"',
    '🚀 "เริ่มต้นเร็ว ยิ่งได้เปรียบ สนุกกับการออมเงินด้วย SaveEz!"',
    '💖 "ออมวันละนิด จิตแจ่มใส ทุกก้าวเข้าใกล้ความฝันขึ้นอีกนิด"',
  ];

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
  }

  // Dynamic Currency Symbol Getter
  String get _currencySymbol {
    if (_currentCurrency.contains('\$') || _currentCurrency.contains('USD')) return '\$';
    if (_currentCurrency.contains('¥') || _currentCurrency.contains('JPY')) return '¥';
    if (_currentCurrency.contains('€') || _currentCurrency.contains('EUR')) return '€';
    return '฿';
  }

  // Exchange Rate Engine (1 THB = X Foreign Currency)
  double get _exchangeRate {
    if (_currentCurrency.contains('USD') || _currentCurrency.contains('\$')) {
      return 1 / 35.0; // 35 THB = $1 USD
    }
    if (_currentCurrency.contains('JPY') || _currentCurrency.contains('¥')) {
      return 4.0; // 1 THB = ¥4 JPY
    }
    if (_currentCurrency.contains('EUR') || _currentCurrency.contains('€')) {
      return 1 / 38.0; // 38 THB = €1 EUR
    }
    return 1.0; // THB
  }

  // Convert base THB amount to active currency value
  double _val(double amountInTHB) {
    return amountInTHB * _exchangeRate;
  }

  // Convert input value in active currency back to base THB
  double _parseToTHB(double valInActiveCurrency) {
    return valInActiveCurrency / _exchangeRate;
  }

  // Format currency text (e.g. $1,000, ฿35,000, ¥140,000)
  String _fmtMoney(double amountInTHB) {
    final double v = _val(amountInTHB);
    if (v >= 1000) {
      return '$_currencySymbol${v.toStringAsFixed(0)}';
    } else if (v < 10 && v > 0) {
      return '$_currencySymbol${v.toStringAsFixed(2)}';
    } else {
      return '$_currencySymbol${v.toStringAsFixed(1)}';
    }
  }

  // Achievement Badges
  final List<AchievementBadge> _achievements = [
    AchievementBadge(
      id: 'a1',
      title: 'หมูน้อยก้าวแรก 🏅',
      description: 'ฝากเงินครั้งแรกเข้ากระปุกออมสินสำเร็จ',
      iconEmoji: '🏅',
      isUnlocked: true,
      unlockRequirement: 'ฝากเงินสำเร็จ 1 ครั้ง',
    ),
    AchievementBadge(
      id: 'a2',
      title: 'สายสปีดวินัยเหล็ก 🔥',
      description: 'ออมเงินติดต่อกัน 7 วัน (7-Day Streak)',
      iconEmoji: '🔥',
      isUnlocked: true,
      unlockRequirement: 'Streak ออมเงินครบ 7 วัน',
    ),
    AchievementBadge(
      id: 'a3',
      title: 'กระปุกใบแรกในชีวิต 👑',
      description: 'ออมเงินครบเป้าหมาย 100% ในกระปุกใบแรก',
      iconEmoji: '👑',
      isUnlocked: true,
      unlockRequirement: 'ออมเงินครบเป้าหมาย 1 กระปุก',
    ),
    AchievementBadge(
      id: 'a4',
      title: 'เศรษฐีหมูทองคำ 💎',
      description: 'สะสมยอดเงินออมรวมเกินเป้าหมาย',
      iconEmoji: '💎',
      isUnlocked: true,
      unlockRequirement: 'เงินออมรวมสะสมครบกำหนด',
    ),
    AchievementBadge(
      id: 'a5',
      title: 'นักออมไร้พ่าย 🚀',
      description: 'ออมเงินติดต่อกัน 30 วัน',
      iconEmoji: '🚀',
      isUnlocked: false,
      unlockRequirement: 'Streak ออมเงินครบ 30 วัน',
    ),
  ];

  // Demo Goals (Base amounts in THB)
  final List<SavingsGoal> _goals = [
    SavingsGoal(
      id: '1',
      title: 'กระปุกโทรศัพท์ใหม่ 📱',
      currentAmount: 18500,
      targetAmount: 35000,
      icon: Icons.phone_iphone_rounded,
      color: const Color(0xFFFF6B8B),
      targetDate: DateTime.now().add(const Duration(days: 90)),
      streakDays: 12,
      lastCheckInDate: DateTime.now().subtract(const Duration(days: 1)),
      isReminderEnabled: true,
      reminderFrequency: 'ทุกวัน เวลา 20:00 น.',
    ),
    SavingsGoal(
      id: '2',
      title: 'กระปุกเที่ยวญี่ปุ่น ⛩️',
      currentAmount: 24000,
      targetAmount: 45000,
      icon: Icons.flight_takeoff_rounded,
      color: const Color(0xFF4ECDC4),
      targetDate: DateTime.now().add(const Duration(days: 120)),
      streakDays: 8,
      lastCheckInDate: DateTime.now().subtract(const Duration(days: 1)),
      isReminderEnabled: true,
      reminderFrequency: 'ทุกวันศุกร์ เวลา 18:00 น.',
    ),
    SavingsGoal(
      id: '3',
      title: 'กระปุกเงินฉุกเฉิน 🛡️',
      currentAmount: 12500,
      targetAmount: 20000,
      icon: Icons.shield_rounded,
      color: const Color(0xFFFFD166),
      targetDate: DateTime.now().add(const Duration(days: 60)),
      streakDays: 15,
      lastCheckInDate: DateTime.now(),
      isReminderEnabled: true,
      reminderFrequency: 'ทุกวันสิ้นเดือน',
    ),
    SavingsGoal(
      id: '4',
      title: 'กระปุกหูฟังไร้สาย 🎧',
      currentAmount: 5900,
      targetAmount: 5900,
      icon: Icons.headphones_rounded,
      color: const Color(0xFF1DD1A1),
      targetDate: DateTime.now().subtract(const Duration(days: 10)),
      isCompleted: true,
      streakDays: 30,
      isReminderEnabled: false,
    ),
  ];

  // Demo Transactions Log (Amounts in THB)
  final List<SavingsTransaction> _transactions = [
    SavingsTransaction(
      id: 't1',
      goalTitle: 'กระปุกเงินฉุกเฉิน 🛡️',
      amount: 500,
      date: DateTime.now(),
      isDeposit: true,
      note: 'เช็กอินออมรายวัน',
    ),
    SavingsTransaction(
      id: 't2',
      goalTitle: 'กระปุกเที่ยวญี่ปุ่น ⛩️',
      amount: 1000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isDeposit: true,
      note: 'ฝากประจำสัปดาห์',
    ),
    SavingsTransaction(
      id: 't3',
      goalTitle: 'กระปุกโทรศัพท์ใหม่ 📱',
      amount: 500,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isDeposit: true,
      note: 'เงินออมพิเศษ',
    ),
  ];

  List<SavingsGoal> get _activeGoals => _goals
      .where((g) => !g.isCompleted && g.title.toLowerCase().contains(_goalSearchQuery.toLowerCase()))
      .toList();

  List<SavingsGoal> get _completedGoals => _goals
      .where((g) => g.isCompleted && g.title.toLowerCase().contains(_goalSearchQuery.toLowerCase()))
      .toList();

  double get _totalSavingsTHB => _goals.fold(0, (sum, item) => sum + item.currentAmount);
  double get _totalTargetTHB => _goals.fold(0, (sum, item) => sum + item.targetAmount);

  // Undo / Reverse Deposit Transaction
  void _undoTransaction(SavingsTransaction tx) {
    final goalIndex = _goals.indexWhere((g) => g.title == tx.goalTitle);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final newCurrentTHB = (goal.currentAmount - tx.amount).clamp(0.0, double.infinity);
      setState(() {
        _goals[goalIndex] = goal.copyWith(
          currentAmount: newCurrentTHB,
          isCompleted: newCurrentTHB >= goal.targetAmount,
        );
        _transactions.removeWhere((t) => t.id == tx.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ย้อนคืนเงิน ${_fmtMoney(tx.amount)} จาก ${tx.goalTitle} เรียบร้อยแล้ว 🔄'),
          backgroundColor: const Color(0xFFFF8E53),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Interactive Badge Detail Dialog
  void _showBadgeDetailDialog(AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(badge.iconEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            Expanded(child: Text(badge.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: badge.isUnlocked ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    badge.isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                    color: badge.isUnlocked ? const Color(0xFF4CAF50) : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      badge.isUnlocked ? 'ปลดล็อกเหรียญรางวัลแล้ว!' : 'เงื่อนไข: ${badge.unlockRequirement}',
                      style: TextStyle(
                        color: badge.isUnlocked ? const Color(0xFF4CAF50) : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  // Monthly Bar Detail Dialog
  void _showBarDetailDialog(String month, double factor) {
    final double monthTotalTHB = 5000 * factor * 5;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.bar_chart_rounded, color: Color(0xFFFF6B8B)),
            const SizedBox(width: 8),
            Text('รายงานเดือน $month 📊', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ยอดออมรวมประจำเดือน $month:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              _fmtMoney(monthTotalTHB),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFFFF6B8B)),
            ),
            const SizedBox(height: 12),
            const Text('วินัยการออมยอดเยี่ยม ยอดเงินเติบโตขึ้นเรื่อยๆ ชัดเจน!', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  // Interactive Reminder Settings Dialog
  void _showReminderSettingsDialog(SavingsGoal goal) {
    String selectedFreq = goal.reminderFrequency;
    bool isEnabled = goal.isReminderEnabled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(goal.icon, color: goal.color),
                const SizedBox(width: 8),
                Expanded(child: Text('ตั้งเตือนฝากเงิน: ${goal.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  activeColor: const Color(0xFFFF6B8B),
                  title: const Text('เปิดการแจ้งเตือน', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: isEnabled,
                  onChanged: (val) {
                    setModalState(() {
                      isEnabled = val;
                    });
                  },
                ),
                if (isEnabled) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedFreq,
                    decoration: InputDecoration(
                      labelText: 'ความถี่การแจ้งเตือน',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ทุกวัน เวลา 20:00 น.', child: Text('ทุกวัน เวลา 20:00 น.')),
                      DropdownMenuItem(value: 'ทุกวันศุกร์ เวลา 18:00 น.', child: Text('ทุกวันศุกร์ เวลา 18:00 น.')),
                      DropdownMenuItem(value: 'ทุกวันสิ้นเดือน', child: Text('ทุกวันสิ้นเดือน')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedFreq = val;
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final index = _goals.indexWhere((g) => g.id == goal.id);
                    if (index != -1) {
                      _goals[index] = goal.copyWith(
                        isReminderEnabled: isEnabled,
                        reminderFrequency: selectedFreq,
                      );
                    }
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('อัปเดตการตั้งเวลาเตือนของ ${goal.title} เรียบร้อยแล้ว! 🔔'),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึก'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Interactive Savings Calculator Dialog
  void _showSavingsCalculatorDialog() {
    final targetController = TextEditingController(text: _val(12000).toStringAsFixed(0));
    final monthsController = TextEditingController(text: '6');
    double dailyCalculated = _val(66.6);
    double monthlyCalculated = _val(2000.0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          void updateCalc() {
            final target = double.tryParse(targetController.text) ?? 0;
            final months = double.tryParse(monthsController.text) ?? 1;
            if (target > 0 && months > 0) {
              setModalState(() {
                monthlyCalculated = target / months;
                dailyCalculated = target / (months * 30.0);
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.calculate_rounded, color: Color(0xFFFF6B8B)),
                SizedBox(width: 8),
                Text('คำนวณแผนออมเงินล่วงหน้า 🧮', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'เป้าหมายเงินออมที่อยากได้',
                    prefixText: '$_currencySymbol ',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => updateCalc(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ระยะเวลาที่ต้องการออม (เดือน)',
                    suffixText: 'เดือน',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => updateCalc(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B8B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ต้องออมต่อวัน:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '$_currencySymbol${dailyCalculated.toStringAsFixed(1)} / วัน',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B8B), fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ต้องออมต่อเดือน:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '$_currencySymbol${monthlyCalculated.toStringAsFixed(0)} / เดือน',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8E53), fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ปิด', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddGoalDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('เริ่มสร้างกระปุกนี้เลย'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Shareable Achievement Card Dialog
  void _showShareableCard(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B8B), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text('SaveEz Achievement 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(goal.icon, color: goal.color, size: 48),
              ),
              const SizedBox(height: 14),
              Text(
                goal.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ออมสำเร็จครบ ${_fmtMoney(goal.targetAmount)} 🎉',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'เจ้าของกระปุก: $_currentUserName $_currentAvatarEmoji',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ปิด', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('บันทึกและคัดลอกการ์ดความสำเร็จพร้อมแชร์แล้ว! 📸✨'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('คัดลอกรูปแชร์'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // Reset All Savings Feature
  void _showResetAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'รีเซ็ตเงินออมทั้งหมด? ⚠️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'การดำเนินการนี้จะปรับยอดเงินออมสะสมในทุกกระปุกกลับเป็น ${_currencySymbol}0 และล้างประวัติการฝากเงินทั้งหมด คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ต?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (int i = 0; i < _goals.length; i++) {
                  _goals[i] = _goals[i].copyWith(
                    currentAmount: 0.0,
                    isCompleted: false,
                    streakDays: 0,
                  );
                }
                _transactions.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('รีเซ็ตยอดเงินออมทั้งหมดกลับเป็น ${_currencySymbol}0 เรียบร้อยแล้ว 🔄'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยันการรีเซ็ตเงินทั้งหมด'),
          ),
        ],
      ),
    );
  }

  // Currency Selector Dialog
  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('เลือกสกุลเงิน 💱 (1 USD = ฿35, 1 EUR = ฿38, 1 THB = ¥4)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          _buildCurrencyOption('THB (฿) - บาทไทย'),
          _buildCurrencyOption('USD (\$) - ดอลลาร์สหรัฐ (1 \$ ≈ ฿35)'),
          _buildCurrencyOption('JPY (¥) - เยนญี่ปุ่น (1 THB ≈ ¥4)'),
          _buildCurrencyOption('EUR (€) - ยูโร (1 € ≈ ฿38)'),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String option) {
    final String currName = option.split(' - ').first;
    final bool isSelected = _currentCurrency == currName;
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _currentCurrency = currName;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เปลี่ยนสกุลเงินเป็น $_currentCurrency พร้อมคำนวณอัตราแลกเปลี่ยนอัตโนมัติแล้ว! ✨'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFFFF6B8B)),
          ],
        ),
      ),
    );
  }

  // Security & PIN Settings Dialog
  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.security_rounded, color: Color(0xFFFF6B8B)),
                SizedBox(width: 8),
                Text('ความปลอดภัย & PIN 🔒', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  activeColor: const Color(0xFFFF6B8B),
                  title: const Text('ล็อคแอปด้วยรหัส PIN / สแกนลายนิ้วมือ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  value: _isPinLockEnabled,
                  onChanged: (val) {
                    setModalState(() {
                      _isPinLockEnabled = val;
                    });
                    setState(() {
                      _isPinLockEnabled = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.pin_rounded, color: Color(0xFFFF6B8B)),
                  title: const Text('เปลี่ยนรหัส PIN 6 หลัก'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ตั้งค่ารหัส PIN ใหม่เรียบร้อยแล้ว! 🔒'),
                        backgroundColor: Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ปิด', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Help & FAQ Dialog
  void _showFaqSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_center_rounded, color: Color(0xFFFF6B8B), size: 28),
                SizedBox(width: 8),
                Text('คำถามที่พบบ่อย (FAQ) ❓', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const ExpansionTile(
              title: Text('เมื่อเปลี่ยนสกุลเงิน ยอดเงินจะแปลงอัตราแลกเปลี่ยนให้อัตโนมัติไหม?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('แปลงอัตราแลกเปลี่ยนคำนวณให้อัตโนมัติครับ เช่น \$1 USD = ฿35, 1 EUR = ฿38, 1 THB = ¥4 JPY ยอดเงินและกระปุกของคุณจะอัปเดตมูลค่าทันที! 💱'),
                )
              ],
            ),
            const ExpansionTile(
              title: Text('ถ้าฝากเงินผิด สามารถย้อนกลับได้ไหม?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('สามารถกดปุ่ม "ย้อนเงินคืน" ที่รายการประวัติการฝากเงินย้อนหลังได้ตลอดเวลาครับ! 🔄'),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('เข้าใจแล้ว'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Deposit & Coin Drop Trigger (Amount in Active Currency)
  void _quickDeposit(double amountInActiveCurrency) {
    if (_activeGoals.isEmpty) return;
    final firstGoal = _activeGoals.first;
    final amountTHB = _parseToTHB(amountInActiveCurrency);

    final newTx = SavingsTransaction(
      id: DateTime.now().toString(),
      goalTitle: firstGoal.title,
      amount: amountTHB,
      date: DateTime.now(),
      isDeposit: true,
      note: 'ฝากเงินด่วน (Squid Game Deposit)',
    );

    setState(() {
      final index = _goals.indexWhere((g) => g.id == firstGoal.id);
      if (index != -1) {
        _goals[index] = firstGoal.copyWith(
          currentAmount: firstGoal.currentAmount + amountTHB,
        );
        _transactions.insert(0, newTx);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('หยอดเหรียญ 🪙 +${_fmtMoney(amountTHB)} เข้า ${firstGoal.title} สำเร็จ!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'ย้อนคืน',
          textColor: Colors.white,
          onPressed: () => _undoTransaction(newTx),
        ),
      ),
    );
  }

  // Edit Profile Dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _currentUserName);
    String selectedEmoji = _currentAvatarEmoji;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.edit_rounded, color: Color(0xFFFF6B8B)),
                SizedBox(width: 8),
                Text('แก้ไขโปรไฟล์ 👤', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('เลือกไอคอนประจำตัว:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _avatarEmojiOptions.map((emoji) {
                    final bool isSelected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF6B8B).withOpacity(0.2) : Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF6B8B) : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้งาน',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    setState(() {
                      _currentUserName = newName;
                      _currentAvatarEmoji = selectedEmoji;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('อัปเดตโปรไฟล์เรียบร้อยแล้ว! ✨'),
                        backgroundColor: Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึกโปรไฟล์'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Quick Check-in
  void _handleQuickCheckIn(SavingsGoal goal) {
    if (goal.isCheckedInToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('คุณออม ${goal.title} ในวันนี้แล้ว 👍 Streak ติดต่อกัน ${goal.streakDays} วัน!'),
          backgroundColor: const Color(0xFFFF8E53),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newStreak = goal.streakDays + 1;
    setState(() {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal.copyWith(
          streakDays: newStreak,
          lastCheckInDate: DateTime.now(),
        );
      }
    });

    _showDepositDialog(goal, isCheckIn: true, streakCount: newStreak);
  }

  // Deposit Dialog (Input in active currency)
  void _showDepositDialog(SavingsGoal goal, {bool isCheckIn = false, int? streakCount}) {
    final amountController = TextEditingController(text: _val(100).toStringAsFixed(0));
    final noteController = TextEditingController(text: isCheckIn ? 'เช็กอินออมประจำวัน' : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(goal.icon, color: goal.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isCheckIn ? '🔥 เช็กอินออมเงินวันนี้!' : 'ฝากเงินเข้า ${goal.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCheckIn && streakCount != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8E53).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'คุณกดออมเงินติดต่อกัน $streakCount วันแล้ว! เก่งมากๆ',
                        style: const TextStyle(
                          color: Color(0xFFFF8E53),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'ยอดออมปัจจุบัน: ${_fmtMoney(goal.currentAmount)} / ${_fmtMoney(goal.targetAmount)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'จำนวนเงินที่ฝาก ($_currentCurrency)',
                prefixText: '$_currencySymbol ',
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'บันทึกเพิ่มเติม (ถ้ามี)',
                hintText: 'เช่น ค่าอาหารประจำวัน',
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final depositInput = double.tryParse(amountController.text);
              if (depositInput != null && depositInput > 0) {
                final depositTHB = _parseToTHB(depositInput);
                final newAmountTHB = goal.currentAmount + depositTHB;
                final bool isNewlyCompleted = newAmountTHB >= goal.targetAmount;
                final newTx = SavingsTransaction(
                  id: DateTime.now().toString(),
                  goalTitle: goal.title,
                  amount: depositTHB,
                  date: DateTime.now(),
                  isDeposit: true,
                  note: noteController.text,
                );

                setState(() {
                  int index = _goals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) {
                    _goals[index] = goal.copyWith(
                      currentAmount: newAmountTHB,
                      isCompleted: isNewlyCompleted ? true : goal.isCompleted,
                    );
                    _transactions.insert(0, newTx);
                  }
                });

                Navigator.pop(ctx);

                // Trigger Squid Game Coin Drop Animation!
                _squidPiggyKey.currentState?.triggerCoinDrop(depositInput);

                if (isNewlyCompleted) {
                  _showCelebrationDialog(goal.copyWith(currentAmount: newAmountTHB));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ฝากเงิน ${_fmtMoney(depositTHB)} เข้า ${goal.title} สำเร็จ!'),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'ย้อนคืน',
                        textColor: Colors.white,
                        onPressed: () => _undoTransaction(newTx),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยันการฝาก'),
          ),
        ],
      ),
    );
  }

  // Celebration Dialog
  void _showCelebrationDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              '🎉 ยินดีด้วยอย่างยิ่ง! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณออมเงินเข้ากระปุก "${goal.title}" ครบเป้าหมาย ${_fmtMoney(goal.targetAmount)} แล้ว!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ตกลง 🏆'),
            ),
          ),
        ],
      ),
    );
  }

  // Edit Goal Dialog
  void _showEditGoalDialog(SavingsGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final currentAmountController = TextEditingController(text: _val(goal.currentAmount).toStringAsFixed(0));
    final targetAmountController = TextEditingController(text: _val(goal.targetAmount).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ปรับแต่งข้อมูลกระปุก ✏️', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'ชื่อกระปุกออมเงิน',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: currentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ยอดเงินปัจจุบัน',
                        prefixText: '$_currencySymbol ',
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: targetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'เป้าหมายเงินออม',
                        prefixText: '$_currencySymbol ',
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              final newCurrentVal = double.tryParse(currentAmountController.text) ?? _val(goal.currentAmount);
              final newTargetVal = double.tryParse(targetAmountController.text) ?? _val(goal.targetAmount);

              final newCurrentTHB = _parseToTHB(newCurrentVal);
              final newTargetTHB = _parseToTHB(newTargetVal);

              setState(() {
                final index = _goals.indexWhere((g) => g.id == goal.id);
                if (index != -1) {
                  _goals[index] = goal.copyWith(
                    title: newTitle,
                    currentAmount: newCurrentTHB,
                    targetAmount: newTargetTHB,
                    isCompleted: newCurrentTHB >= newTargetTHB,
                  );
                }
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // Create Goal Dialog with Icon and Color Selector
  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    IconData selectedIcon = Icons.savings_rounded;
    Color selectedColor = const Color(0xFFFF6B8B);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('สร้างกระปุกใหม่ 🐷', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อเป้าหมายการออม',
                      hintText: 'เช่น ซื้อโน้ตบุ๊กใหม่',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'เป้าหมายเงินออม ($_currentCurrency)',
                      prefixText: '$_currencySymbol ',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('เลือกไอคอนประจำกระปุก:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _goalIconOptions.length,
                      itemBuilder: (context, i) {
                        final item = _goalIconOptions[i];
                        final IconData ic = item['icon'];
                        final bool isSel = selectedIcon == ic;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedIcon = ic;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSel ? selectedColor.withOpacity(0.2) : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSel ? selectedColor : Colors.transparent, width: 2.5),
                            ),
                            child: Icon(ic, color: isSel ? selectedColor : Colors.grey[600], size: 22),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('เลือกสีประจำกระปุก:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _goalColorOptions.map((c) {
                      final bool isSel = selectedColor == c;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedColor = c;
                          });
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: c,
                          child: isSel ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final targetVal = double.tryParse(targetController.text);

                  if (title.isNotEmpty && targetVal != null && targetVal > 0) {
                    final targetTHB = _parseToTHB(targetVal);
                    setState(() {
                      _goals.add(
                        SavingsGoal(
                          id: DateTime.now().toString(),
                          title: title,
                          currentAmount: 0,
                          targetAmount: targetTHB,
                          icon: selectedIcon,
                          color: selectedColor,
                          targetDate: DateTime.now().add(const Duration(days: 90)),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('สร้างกระปุก'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? const Color(0xFF1E1B2E) : const Color(0xFFFAF9F6);
    final cardColor = _isDarkMode ? const Color(0xFF28243D) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: Row(
          children: [
            const Icon(Icons.savings_rounded, color: Color(0xFFFF6B8B), size: 28),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'Save',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                children: const [
                  TextSpan(
                    text: 'Ez',
                    style: TextStyle(color: Color(0xFFFF6B8B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isDarkMode ? 'สลับเป็นธีมสว่าง' : 'สลับเป็นธีมมืด',
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: const Color(0xFFFF6B8B),
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          IconButton(
            tooltip: 'แก้ไขโปรไฟล์',
            icon: Text(_currentAvatarEmoji, style: const TextStyle(fontSize: 22)),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Body View Switcher
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeTab(textColor, cardColor),
          _buildGoalsTab(textColor, cardColor),
          _buildAnalyticsTab(textColor, cardColor),
          _buildRemindersTab(textColor, cardColor),
          _buildProfileTab(textColor, cardColor),
        ],
      ),

      // Standard Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardColor,
          selectedItemColor: const Color(0xFFFF6B8B),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'หน้าหลัก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_rounded),
              label: 'กระปุกออมเงิน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'สถิติ & รายงาน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_rounded),
              label: 'แจ้งเตือน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'โปรไฟล์',
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: HOME OVERVIEW
  Widget _buildHomeTab(Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header with Editable Profile Avatar
              Row(
                children: [
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFF6B8B).withOpacity(0.15),
                      child: Text(_currentAvatarEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'สวัสดี, $_currentUserName 👋',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                              onPressed: _showEditProfileDialog,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        Text(
                          'หยอดเหรียญลงกระปุกทองคำวันนี้กันเถอะ!',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  // Calculator Quick Button
                  IconButton(
                    tooltip: 'คำนวณแผนออมเงินล่วงหน้า',
                    icon: const Icon(Icons.calculate_outlined, color: Color(0xFFFF6B8B), size: 28),
                    onPressed: _showSavingsCalculatorDialog,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Daily Inspiring Quote Banner (Tap to cycle quote)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _quoteIndex = (_quoteIndex + 1) % _dailyQuotes.length;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.5)),
                  ),
                  child: Text(
                    _dailyQuotes[_quoteIndex % _dailyQuotes.length],
                    style: TextStyle(color: _isDarkMode ? Colors.white : const Color(0xFF7A4A00), fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // SQUID GAME STYLE PIGGY BANK COIN DROP CARD 🪙🐷
              SquidGamePiggyCard(
                key: _squidPiggyKey,
                totalSavings: _val(_totalSavingsTHB),
                totalTarget: _val(_totalTargetTHB),
                currencySymbol: _currencySymbol,
                onQuickDeposit: _quickDeposit,
              ),
              const SizedBox(height: 24),

              // Active Goals Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('กระปุกกำลังออม 🐷',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  TextButton(
                    onPressed: () => setState(() => _currentNavIndex = 1),
                    child: const Text('ดูทั้งหมด', style: TextStyle(color: Color(0xFFFF6B8B))),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeGoals.length.clamp(0, 2),
                itemBuilder: (context, i) => _buildSimpleGoalCard(_activeGoals[i], cardColor, textColor),
              ),
              const SizedBox(height: 20),

              // Recent Log with Undo Action Button
              Text('ประวัติการฝากเงินล่าสุด 📜',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final tx = _transactions[i];
                    return ListTile(
                      onTap: () => _undoTransaction(tx),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.12),
                        child: const Icon(Icons.arrow_downward, color: Color(0xFF4CAF50), size: 18),
                      ),
                      title: Text(tx.goalTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      subtitle: Text('${tx.note.isNotEmpty ? "${tx.note} • " : ""}${tx.date.day}/${tx.date.month}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('+${_fmtMoney(tx.amount)}',
                              style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.undo_rounded, size: 18, color: Colors.orange),
                            tooltip: 'ย้อนเงินคืน (ฝากผิด)',
                            onPressed: () => _undoTransaction(tx),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 2: SAVINGS GOALS (WITH SEARCH BAR)
  Widget _buildGoalsTab(Color textColor, Color cardColor) {
    final displayList = _goalsTab == 0 ? _activeGoals : _completedGoals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('กระปุกออมเงินของฉัน 🐷',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  ElevatedButton.icon(
                    onPressed: _showAddGoalDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('สร้างกระปุก'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B8B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Goal Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหากระปุกออมเงิน...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF6B8B)),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _goalSearchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Segment Filter Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _goalsTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _goalsTab == 0 ? const Color(0xFFFF6B8B) : (_isDarkMode ? const Color(0xFF28243D) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'กำลังออมเงิน (${_activeGoals.length})',
                            style: TextStyle(
                              color: _goalsTab == 0 ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _goalsTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _goalsTab == 1 ? const Color(0xFF4CAF50) : (_isDarkMode ? const Color(0xFF28243D) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'ออมสำเร็จแล้ว (${_completedGoals.length})',
                            style: TextStyle(
                              color: _goalsTab == 1 ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (displayList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('ไม่พบกระปุกออมเงินที่ค้นหา', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (ctx, index) => _buildDetailedGoalCard(displayList[index], cardColor, textColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 3: ANALYTICS, REPORTS & ACHIEVEMENTS
  Widget _buildAnalyticsTab(Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สถิติ & รายงานการออม 📊',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 6),
              Text('ภาพรวมการเติบโตของวินัยทางการเงินของคุณ', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 20),

              // Monthly Savings Trend Chart (Clickable Bars)
              Card(
                color: cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยอดเงินออมรายเดือน (ปี 2024)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('ม.ค.', 0.4, textColor),
                            _buildBar('ก.พ.', 0.55, textColor),
                            _buildBar('มี.ค.', 0.35, textColor),
                            _buildBar('เม.ย.', 0.7, textColor),
                            _buildBar('พ.ค.', 0.85, textColor),
                            _buildBar('มิ.ย.', 1.0, textColor, isHighest: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Achievement Badges Section (Clickable Badges)
              Text('เหรียญตราความสำเร็จ (Achievements) 🏆',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final badge = _achievements[index];
                  return InkWell(
                    onTap: () => _showBadgeDetailDialog(badge),
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      color: badge.isUnlocked
                          ? const Color(0xFFFFD166).withOpacity(0.18)
                          : cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: badge.isUnlocked ? const Color(0xFFFFD166) : Colors.grey[300]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Text(badge.iconEmoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    badge.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    badge.isUnlocked ? 'ปลดล็อกแล้ว!' : badge.unlockRequirement,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: badge.isUnlocked ? const Color(0xFFD85A00) : Colors.grey[500],
                                      fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 4: REMINDERS & NOTIFICATIONS (CLICKABLE LIST TILES)
  Widget _buildRemindersTab(Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ตารางเตือนความจำฝากเงิน 🔔',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 6),
              Text('ตั้งเวลาเตือนความจำเพื่อไม่ให้พลาดเป้าหมายการออม', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeGoals.length,
                itemBuilder: (context, i) {
                  final goal = _activeGoals[i];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      onTap: () => _showReminderSettingsDialog(goal),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goal.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(goal.icon, color: goal.color),
                      ),
                      title: Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: Text(
                        goal.isReminderEnabled ? 'เตือน: ${goal.reminderFrequency}' : 'ปิดการแจ้งเตือน',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      trailing: Switch(
                        activeColor: const Color(0xFFFF6B8B),
                        value: goal.isReminderEnabled,
                        onChanged: (val) {
                          setState(() {
                            final index = _goals.indexWhere((g) => g.id == goal.id);
                            if (index != -1) {
                              _goals[index] = goal.copyWith(isReminderEnabled: val);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 5: PROFILE & SETTINGS (ALL COLUMNS CLICKABLE)
  Widget _buildProfileTab(Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFFF6B8B),
                  child: Text(_currentAvatarEmoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentUserName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                    onPressed: _showEditProfileDialog,
                  ),
                ],
              ),
              Text('สมาชิก SaveEz Premium 🌟', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 24),

              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: Text('แก้ไขชื่อและไอคอนโปรไฟล์', style: TextStyle(color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showEditProfileDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calculate_outlined, color: Color(0xFFFF6B8B)),
                      title: Text('เครื่องมือคำนวณแผนการออมเงิน', style: TextStyle(color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showSavingsCalculatorDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded, color: Color(0xFFFF6B8B)),
                      title: Text('สกุลเงินการออม', style: TextStyle(color: textColor)),
                      trailing: Text(_currentCurrency, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B8B))),
                      onTap: _showCurrencyDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6B8B)),
                      title: Text('การแจ้งเตือน & เวลาออมเงิน', style: TextStyle(color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        setState(() => _currentNavIndex = 3);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: Text('รหัสผ่านและความปลอดภัย', style: TextStyle(color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showSecurityDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: Text('ศูนย์ช่วยเหลือและคำถามที่พบบ่อย (FAQ)', style: TextStyle(color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showFaqSheet,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.refresh_rounded, color: Colors.red),
                      title: const Text('รีเซ็ตเงินออมทั้งหมด (Reset All)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      onTap: _showResetAllConfirmationDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple Goal Card for Home
  Widget _buildSimpleGoalCard(SavingsGoal goal, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => _showDepositDialog(goal),
        leading: Icon(goal.icon, color: goal.color, size: 28),
        title: Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
        subtitle: Text('ออมวันละ ${_fmtMoney(goal.dailySavingsNeeded)} • เหลืออีก ${goal.daysRemaining} วัน',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () => _showDepositDialog(goal),
          style: ElevatedButton.styleFrom(
            backgroundColor: goal.color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('ฝากเงิน'),
        ),
      ),
    );
  }

  // Detailed Goal Card for Goals Tab
  Widget _buildDetailedGoalCard(SavingsGoal goal, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showEditGoalDialog(goal),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text('💡 ต้องหยอดวันละ ${_fmtMoney(goal.dailySavingsNeeded)}',
                          style: const TextStyle(color: Color(0xFFFF6B8B), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFFFF6B8B)),
                  tooltip: 'แชร์การ์ดความสำเร็จ',
                  onPressed: () => _showShareableCard(goal),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  onPressed: () => _showEditGoalDialog(goal),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_fmtMoney(goal.currentAmount)} / ${_fmtMoney(goal.targetAmount)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text('${(goal.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontWeight: FontWeight.bold, color: goal.color)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                if (!goal.isCompleted)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleQuickCheckIn(goal),
                      icon: const Text('🔥'),
                      label: Text(goal.isCheckedInToday ? 'ออมวันนี้แล้ว' : 'ออมแล้ววันนี้'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: goal.isCheckedInToday ? const Color(0xFF4CAF50) : const Color(0xFFFF8E53),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                if (!goal.isCompleted) const SizedBox(width: 8),
                if (!goal.isCompleted)
                  ElevatedButton.icon(
                    onPressed: () => _showDepositDialog(goal),
                    icon: const Icon(Icons.savings_rounded, size: 16),
                    label: const Text('ฝากเงิน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goal.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom painted bar for trend chart (Clickable)
  Widget _buildBar(String month, double factor, Color textColor, {bool isHighest = false}) {
    return GestureDetector(
      onTap: () => _showBarDetailDialog(month, factor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 22,
            height: 130 * factor,
            decoration: BoxDecoration(
              color: isHighest ? const Color(0xFFFF6B8B) : const Color(0xFFFF6B8B).withOpacity(0.35),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(month, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
