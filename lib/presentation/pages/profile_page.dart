import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pro_page.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../../core/api/api_client.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFDD233B)));
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(ProfileLoadRequested()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final stats = state.stats;
            final achievements = state.achievements;

            final isPro = user['is_pro'] == true;
            final username = user['username'] ?? 'Игрок';
            
            final totalScore = stats['total_score'] ?? 0;
            final totalWins = stats['total_wins'] ?? 0;
            final bestStreak = stats['best_streak'] ?? 0;
            final winRate = stats['win_rate'] ?? 0.0;

            final unlockedCount = achievements.where((a) => a['unlocked'] == true).length;

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // ── GRADIENT HEADER ──
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFDD233B), Color(0xFF7C0A2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: Column(
                        children: [
                          // Avatar + Name
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
                                ),
                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(username,
                                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(isPro ? Icons.workspace_premium : Icons.star_rounded, 
                                               color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(isPro ? 'PRO' : 'Стандарт', 
                                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Stats Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _stat('$totalScore', 'Очков'),
                                _vertDivider(),
                                _stat('$totalWins', 'Побед'),
                                _vertDivider(),
                                _stat('$bestStreak', 'Дней'),
                                _vertDivider(),
                                _stat('${winRate.toInt()}%', 'Успех'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── PRO CARD ──
                if (!isPro)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProPage())),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.diamond_rounded, color: Colors.amber, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Перейти на PRO',
                                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                  Text('Безлимитные подсказки · AI-коуч',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('7 дней free',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (!isPro) const SizedBox(height: 28),

                // ── ACHIEVEMENTS ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Достижения',
                              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                          Text('$unlockedCount из ${achievements.length}',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: achievements.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final ach = achievements[index];
                          // Map backend icons to Flutter Icons roughly
                          IconData getIcon(String name) {
                            switch(name) {
                              case 'emoji_events_rounded': return Icons.emoji_events_rounded;
                              case 'local_fire_department_rounded': return Icons.local_fire_department_rounded;
                              case 'bolt_rounded': return Icons.bolt_rounded;
                              case 'psychology_rounded': return Icons.psychology_rounded;
                              case 'stars_rounded': return Icons.stars_rounded;
                              case 'military_tech_rounded': return Icons.military_tech_rounded;
                              default: return Icons.star;
                            }
                          }
                          
                          // Default colors based on backend keys
                          Color getColor(String key) {
                            switch(key) {
                              case 'winner': return const Color(0xFFF59E0B);
                              case 'fire': return const Color(0xFFDD233B);
                              case 'lightning': return const Color(0xFF8B5CF6);
                              case 'strategist': return const Color(0xFF3B82F6);
                              case 'expert': return const Color(0xFFDD233B);
                              case 'champion': return const Color(0xFF10B981);
                              default: return const Color(0xFF3B82F6);
                            }
                          }

                          return _badge(
                            getIcon(ach['icon']), 
                            ach['title'], 
                            getColor(ach['key']), 
                            ach['unlocked'] == true, 
                            ach['description'],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── SETTINGS ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Аккаунт',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      _settingsCard([
                        _settingRow(
                          Icons.person_outline_rounded, 
                          'Редактировать профиль', 
                          const Color(0xFF3B82F6), 
                          () => _showEditProfileDialog(context, username)
                        ),
                        _dividerLine(),
                        _settingRow(Icons.notifications_none_rounded, 'Уведомления', const Color(0xFFF59E0B), () => _showComingSoon(context, 'Настройки уведомлений')),
                        _dividerLine(),
                        _settingRow(Icons.language_rounded, 'Язык приложения', const Color(0xFF10B981), () => _showLanguageDialog(context)),
                      ]),

                      const SizedBox(height: 16),

                      Text('Прочее',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      _settingsCard([
                        _settingRow(Icons.share_rounded, 'Поделиться приложением', const Color(0xFF8B5CF6), () => _showComingSoon(context, 'Функция "Поделиться"')),
                        _dividerLine(),
                        _settingRow(Icons.star_outline_rounded, 'Оценить приложение', const Color(0xFFF59E0B), () => _showComingSoon(context, 'Оценка в магазине')),
                        _dividerLine(),
                        _settingRow(Icons.help_outline_rounded, 'Поддержка', const Color(0xFF06B6D4), () => _showComingSoon(context, 'Служба поддержки')),
                      ]),

                      const SizedBox(height: 16),

                      _settingsCard([
                        _settingRow(
                          Icons.logout_rounded, 
                          'Выйти из аккаунта', 
                          const Color(0xFFDD233B),
                          () => _showLogoutConfirm(context), 
                          isDestructive: true
                        ),
                      ]),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _stat(String val, String label) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2));
  }

  Widget _badge(IconData icon, String label, Color color, bool unlocked, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? color.withOpacity(0.25) : Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: unlocked ? color : Colors.grey.shade300, size: 28),
          const SizedBox(height: 5),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? const Color(0xFF0F172A) : Colors.grey.shade400),
              textAlign: TextAlign.center),
          Text(hint, 
               textAlign: TextAlign.center,
               style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _dividerLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$title скоро появится!', style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Язык приложения', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Русский', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.check_circle, color: Color(0xFFDD233B)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                title: Text('English', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _showComingSoon(context, 'Английский язык');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Имя пользователя', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Введите имя',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Отмена', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty && newName != currentName) {
                        try {
                          await ApiClient().updateProfile(username: newName);
                          if (context.mounted) {
                            context.read<ProfileBloc>().add(ProfileLoadRequested());
                          }
                        } catch (_) {}
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD233B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Сохранить', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFDD233B).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDD233B), size: 32),
            ),
            const SizedBox(height: 16),
            Text('Выйти из аккаунта?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text('Вам придется заново ввести свои данные для входа.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Отмена', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD233B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('Выйти', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(IconData icon, String title, Color color, VoidCallback? onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? const Color(0xFFDD233B) : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (!isDestructive)
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
