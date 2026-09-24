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

  late String _currentUserName;
  String _currentAvatarEmoji = '🐷';
  String _currentCurrency = 'THB (฿)';
  bool _isPinLockEnabled = true;

  final GlobalKey<SquidGamePiggyCardState> _squidPiggyKey = GlobalKey();

  final List<String> _avatarEmojiOptions = ['🐷', '👑', '🦄', '🐱', '🦊', '🐻', '🦁', '💎', '🚀', '🤖'];

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
  }

  // Demo Goals
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

  // Demo Transactions Log
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

  List<SavingsGoal> get _activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<SavingsGoal> get _completedGoals => _goals.where((g) => g.isCompleted).toList();

  double get _totalSavings => _goals.fold(0, (sum, item) => sum + item.currentAmount);
  double get _totalTarget => _goals.fold(0, (sum, item) => sum + item.targetAmount);

  // Undo / Reverse Deposit Transaction (ย้อนคืนเงินเมื่อกดฝากผิด)
  void _undoTransaction(SavingsTransaction tx) {
    final goalIndex = _goals.indexWhere((g) => g.title == tx.goalTitle);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final newCurrent = (goal.currentAmount - tx.amount).clamp(0.0, double.infinity);
      setState(() {
        _goals[goalIndex] = goal.copyWith(
          currentAmount: newCurrent,
          isCompleted: newCurrent >= goal.targetAmount,
        );
        _transactions.removeWhere((t) => t.id == tx.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ย้อนคืนเงิน ฿${tx.amount.toStringAsFixed(0)} จาก ${tx.goalTitle} เรียบร้อยแล้ว 🔄'),
          backgroundColor: const Color(0xFFFF8E53),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Reset All Savings Feature (รีเซ็ตเงินออมทั้งหมดพร้อมหน้าต่างยืนยัน)
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
        content: const Text(
          'การดำเนินการนี้จะปรับยอดเงินออมสะสมในทุกกระปุกกลับเป็น ฿0 และล้างประวัติการฝากเงินทั้งหมด คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ต?',
          style: TextStyle(fontSize: 14),
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
                const SnackBar(
                  content: Text('รีเซ็ตยอดเงินออมทั้งหมดกลับเป็น ฿0 เรียบร้อยแล้ว 🔄'),
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
        title: const Text('เลือกสกุลเงิน 💱', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          _buildCurrencyOption('THB (฿) - บาทไทย'),
          _buildCurrencyOption('USD (\$) - ดอลลาร์สหรัฐ'),
          _buildCurrencyOption('JPY (¥) - เยนญี่ปุ่น'),
          _buildCurrencyOption('EUR (€) - ยูโร'),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String option) {
    final bool isSelected = _currentCurrency == option.split(' - ').first;
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _currentCurrency = option.split(' - ').first;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เปลี่ยนสกุลเงินเป็น $_currentCurrency เรียบร้อยแล้ว!'),
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
            Text(option, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
              title: Text('ถ้าฝากเงินผิด สามารถย้อนกลับได้ไหม?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('สามารถกดปุ่ม "ย้อนเงินคืน" ที่รายการประวัติการฝากเงินย้อนหลังได้ตลอดเวลาครับ! 🔄'),
                )
              ],
            ),
            const ExpansionTile(
              title: Text('กระปุกหมูทองคำ Squid Game ทำงานอย่างไร?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('เมื่อกดฝากเงิน เหรียญทองคำ 🪙 จะตกลงมาจากด้านบนเข้าสู่กระปุกแก้วหมูทองคำ พร้อมแสดงยอดสะสมและเปอร์เซ็นต์แบบเรียลไทม์!'),
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

  // Quick Deposit & Coin Drop Trigger
  void _quickDeposit(double amount) {
    if (_activeGoals.isEmpty) return;
    final firstGoal = _activeGoals.first;
    final newTx = SavingsTransaction(
      id: DateTime.now().toString(),
      goalTitle: firstGoal.title,
      amount: amount,
      date: DateTime.now(),
      isDeposit: true,
      note: 'ฝากเงินด่วน (Squid Game Deposit)',
    );

    setState(() {
      final index = _goals.indexWhere((g) => g.id == firstGoal.id);
      if (index != -1) {
        _goals[index] = firstGoal.copyWith(
          currentAmount: firstGoal.currentAmount + amount,
        );
        _transactions.insert(0, newTx);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('หยอดเหรียญ 🪙 +฿${amount.toStringAsFixed(0)} เข้า ${firstGoal.title} สำเร็จ!'),
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

  // Deposit Dialog
  void _showDepositDialog(SavingsGoal goal, {bool isCheckIn = false, int? streakCount}) {
    final amountController = TextEditingController(text: '100');
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
              'ยอดออมปัจจุบัน: ฿${goal.currentAmount.toStringAsFixed(0)} / ฿${goal.targetAmount.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'จำนวนเงินที่ฝาก (บาท)',
                prefixText: '฿ ',
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
              final depositAmount = double.tryParse(amountController.text);
              if (depositAmount != null && depositAmount > 0) {
                final newAmount = goal.currentAmount + depositAmount;
                final bool isNewlyCompleted = newAmount >= goal.targetAmount;
                final newTx = SavingsTransaction(
                  id: DateTime.now().toString(),
                  goalTitle: goal.title,
                  amount: depositAmount,
                  date: DateTime.now(),
                  isDeposit: true,
                  note: noteController.text,
                );

                setState(() {
                  int index = _goals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) {
                    _goals[index] = goal.copyWith(
                      currentAmount: newAmount,
                      isCompleted: isNewlyCompleted ? true : goal.isCompleted,
                    );
                    _transactions.insert(0, newTx);
                  }
                });

                Navigator.pop(ctx);

                // Trigger Squid Game Coin Drop Animation!
                _squidPiggyKey.currentState?.triggerCoinDrop(depositAmount);

                if (isNewlyCompleted) {
                  _showCelebrationDialog(goal.copyWith(currentAmount: newAmount));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ฝากเงิน ฿${depositAmount.toStringAsFixed(0)} เข้า ${goal.title} สำเร็จ!'),
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
              'คุณออมเงินเข้ากระปุก "${goal.title}" ครบเป้าหมาย ฿${goal.targetAmount.toStringAsFixed(0)} แล้ว!',
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
    final currentAmountController = TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    final targetAmountController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));

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
                        prefixText: '฿ ',
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
                        prefixText: '฿ ',
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
              final newCurrent = double.tryParse(currentAmountController.text) ?? goal.currentAmount;
              final newTarget = double.tryParse(targetAmountController.text) ?? goal.targetAmount;

              setState(() {
                final index = _goals.indexWhere((g) => g.id == goal.id);
                if (index != -1) {
                  _goals[index] = goal.copyWith(
                    title: newTitle,
                    currentAmount: newCurrent,
                    targetAmount: newTarget,
                    isCompleted: newCurrent >= newTarget,
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

  // Create Goal Dialog
  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

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
                      labelText: 'เป้าหมายเงินออม (บาท)',
                      prefixText: '฿ ',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
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
                  final target = double.tryParse(targetController.text);

                  if (title.isNotEmpty && target != null && target > 0) {
                    setState(() {
                      _goals.add(
                        SavingsGoal(
                          id: DateTime.now().toString(),
                          title: title,
                          currentAmount: 0,
                          targetAmount: target,
                          icon: Icons.savings_rounded,
                          color: const Color(0xFFFF6B8B),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.savings_rounded, color: Color(0xFFFF6B8B), size: 28),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                text: 'Save',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                children: [
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
          _buildHomeTab(),
          _buildGoalsTab(),
          _buildAnalyticsTab(),
          _buildRemindersTab(),
          _buildProfileTab(),
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
  Widget _buildHomeTab() {
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
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // SQUID GAME STYLE PIGGY BANK COIN DROP CARD 🪙🐷
              SquidGamePiggyCard(
                key: _squidPiggyKey,
                totalSavings: _totalSavings,
                totalTarget: _totalTarget,
                onQuickDeposit: _quickDeposit,
              ),
              const SizedBox(height: 24),

              // Active Goals Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('กระปุกกำลังออม 🐷',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
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
                itemBuilder: (context, i) => _buildSimpleGoalCard(_activeGoals[i]),
              ),
              const SizedBox(height: 20),

              // Recent Log with Undo Action Button
              const Text('ประวัติการฝากเงินล่าสุด 📜',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.12),
                        child: const Icon(Icons.arrow_downward, color: Color(0xFF4CAF50), size: 18),
                      ),
                      title: Text(tx.goalTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('${tx.note.isNotEmpty ? "${tx.note} • " : ""}${tx.date.day}/${tx.date.month}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('+฿${tx.amount.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
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

  // TAB 2: SAVINGS GOALS
  Widget _buildGoalsTab() {
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
                  const Text('กระปุกออมเงินของฉัน 🐷',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
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
              const SizedBox(height: 16),

              // Segment Filter Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _goalsTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _goalsTab == 0 ? const Color(0xFFFF6B8B) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'กำลังออมเงิน (${_activeGoals.length})',
                            style: TextStyle(
                              color: _goalsTab == 0 ? Colors.white : Colors.grey[700],
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
                          color: _goalsTab == 1 ? const Color(0xFF4CAF50) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'ออมสำเร็จแล้ว (${_completedGoals.length})',
                            style: TextStyle(
                              color: _goalsTab == 1 ? Colors.white : Colors.grey[700],
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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (ctx, index) => _buildDetailedGoalCard(displayList[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 3: ANALYTICS & REPORTS
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('สถิติ & รายงานการออม 📊',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              const SizedBox(height: 6),
              Text('ภาพรวมการเติบโตของวินัยทางการเงินของคุณ', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),

              // Monthly Savings Trend Chart
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ยอดเงินออมรายเดือน (ปี 2024)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('ม.ค.', 0.4),
                            _buildBar('ก.พ.', 0.55),
                            _buildBar('มี.ค.', 0.35),
                            _buildBar('เม.ย.', 0.7),
                            _buildBar('พ.ค.', 0.85),
                            _buildBar('มิ.ย.', 1.0, isHighest: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Streak & Milestones Summary
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: const Color(0xFFFF8E53).withOpacity(0.12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('🔥 Streak สูงสุด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(height: 4),
                            Text('30 วัน', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF8E53))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('🏆 ออมสำเร็จแล้ว', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(height: 4),
                            Text('1 กระปุก', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 4: REMINDERS & NOTIFICATIONS
  Widget _buildRemindersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ตารางเตือนความจำฝากเงิน 🔔',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              const SizedBox(height: 6),
              Text('ตั้งเวลาเตือนความจำเพื่อไม่ให้พลาดเป้าหมายการออม', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeGoals.length,
                itemBuilder: (context, i) {
                  final goal = _activeGoals[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      activeColor: const Color(0xFFFF6B8B),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goal.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(goal.icon, color: goal.color),
                      ),
                      title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        goal.isReminderEnabled ? 'เตือน: ${goal.reminderFrequency}' : 'ปิดการแจ้งเตือน',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
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
  Widget _buildProfileTab() {
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
                  Text(_currentUserName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                    onPressed: _showEditProfileDialog,
                  ),
                ],
              ),
              Text('สมาชิก SaveEz Premium 🌟', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: const Text('แก้ไขชื่อและไอคอนโปรไฟล์'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showEditProfileDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded, color: Color(0xFFFF6B8B)),
                      title: const Text('สกุลเงินการออม'),
                      trailing: Text(_currentCurrency, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B8B))),
                      onTap: _showCurrencyDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6B8B)),
                      title: const Text('การแจ้งเตือน & เวลาออมเงิน'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        setState(() => _currentNavIndex = 3); // Switch to Reminders tab
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: const Text('รหัสผ่านและความปลอดภัย'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showSecurityDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded, color: Color(0xFFFF6B8B)),
                      title: const Text('ศูนย์ช่วยเหลือและคำถามที่พบบ่อย (FAQ)'),
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
  Widget _buildSimpleGoalCard(SavingsGoal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(goal.icon, color: goal.color, size: 28),
        title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('ออมวันละ ฿${goal.dailySavingsNeeded.toStringAsFixed(0)} • เหลืออีก ${goal.daysRemaining} วัน',
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

  // Detailed Goal Card for Goals Tab (Icon-based)
  Widget _buildDetailedGoalCard(SavingsGoal goal) {
    return Card(
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('💡 ต้องหยอดวันละ ฿${goal.dailySavingsNeeded.toStringAsFixed(0)}',
                          style: const TextStyle(color: Color(0xFFFF6B8B), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                Text('฿${goal.currentAmount.toStringAsFixed(0)} / ฿${goal.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // Custom painted bar for trend chart
  Widget _buildBar(String month, double factor, {bool isHighest = false}) {
    return Column(
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
        Text(month, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
