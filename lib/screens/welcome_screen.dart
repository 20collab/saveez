import 'package:flutter/material.dart';
import '../widgets/piggy_bank_icon.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Container(
              constraints: BoxConstraints(maxWidth: isWeb ? 820 : 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Piggy Mascot Hero Animation Widget
                  const PiggyBankDecoration(
                    size: 150,
                    primaryColor: Color(0xFFFF6B8B),
                    badgeColor: Color(0xFFFFD166),
                    badgeText: 'SaveEz 🐷',
                  ),
                  const SizedBox(height: 24), // Comfortable brand spacing

                  // Title & Tagline with High Contrast (#1E2029 & #2D3142)
                  Text(
                    'SaveEz',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2029),
                      fontSize: 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กระปุกออมเงินออนไลน์สำหรับทุกคน 🐷✨',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFFF6B8B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // High Contrast Description Text (#333333)
                  Text(
                    'เริ่มต้นสร้างวินัยทางการเงินอย่างง่ายดาย ตั้งเป้าหมายออมเงิน ซื้อของในฝัน ท่องเที่ยว หรือเงินสำรองฉุกเฉิน!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF333333),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Social Proof Badges (จุดเด่นสั้นๆ)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSocialProofChip('✨ ออมง่าย ไม่ต้องเชื่อมบัญชี'),
                      _buildSocialProofChip('🎯 ตั้งเป้าหมายได้ไม่จำกัด'),
                      _buildSocialProofChip('🔒 ปลอดภัย 100%'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Feature Highlights Cards (Responsive Layout)
                  if (isWeb)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.savings_rounded,
                            color: const Color(0xFFFF6B8B),
                            title: 'แยกกระปุกตามเป้าหมาย',
                            subtitle: 'แบ่งสัดส่วนเงินออมซื้อของ ท่องเที่ยว หรือเงินสำรองได้อย่างชัดเจน',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.pie_chart_rounded,
                            color: const Color(0xFFFF8E53),
                            title: 'ติดตามความคืบหน้า',
                            subtitle: 'ดูเปอร์เซ็นต์ความสำเร็จ สถิติการออม และคำนวณเงินออมต่อวัน',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.verified_user_rounded,
                            color: const Color(0xFF4CAF50),
                            title: 'ใช้งานง่าย ปลอดภัย',
                            subtitle: 'บันทึกการออม ตั้งเตือนความจำ และใช้งานสะดวกสบาย',
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B8B).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.savings_rounded,
                            color: const Color(0xFFFF6B8B),
                            title: 'แยกกระปุกตามเป้าหมาย',
                            subtitle: 'แบ่งสัดส่วนเงินออมซื้อของ ท่องเที่ยว หรือเงินสำรอง',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          _buildFeatureItem(
                            icon: Icons.pie_chart_rounded,
                            color: const Color(0xFFFF8E53),
                            title: 'ติดตามความคืบหน้าเรียลไทม์',
                            subtitle: 'ดูเปอร์เซ็นต์ความสำเร็จและคำนวณเงินออมต่อวัน',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          _buildFeatureItem(
                            icon: Icons.verified_user_rounded,
                            color: const Color(0xFF4CAF50),
                            title: 'ใช้งานง่าย ปลอดภัย',
                            subtitle: 'บันทึกการออม ตั้งเตือนความจำ และใช้งานสะดวก',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 36),

                  // Action Buttons Section with Cute Cartoon Rounded Corners (BorderRadius: 24)
                  // 1. Sign Up Button (สมัครสมาชิกใหม่ - Primary CTA)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 22),
                      label: const Text(
                        'สมัครสมาชิกใหม่',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B8B),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFFF6B8B).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Login Button (เข้าสู่ระบบ - Secondary CTA)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 20, color: Color(0xFFFF6B8B)),
                      label: const Text(
                        'เข้าสู่ระบบด้วยบัญชีที่มีอยู่',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B8B),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B8B), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Prominent Demo Button Chip
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(userName: 'ผู้ทดลองใช้งาน'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B8B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF6B8B).withOpacity(0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            size: 20,
                            color: Color(0xFFFF6B8B),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ข้ามไปลองใช้งานเดโม (Demo Mode)',
                            style: TextStyle(
                              color: Color(0xFFFF6B8B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFFFF6B8B),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Social Proof Chip Badge
  Widget _buildSocialProofChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8E53).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF8E53).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD85A00),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Feature Card for Web Grid
  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B8B).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E2029),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Feature Item for Mobile Vertical List
  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E2029),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
