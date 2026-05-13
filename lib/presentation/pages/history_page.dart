import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/history/history_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTab = 0; // 0 = all, 1 = wins only

  Color _getDifficultyColor(String diff) {
    switch (diff) {
      case 'easy': return const Color(0xFF10B981);
      case 'medium': return const Color(0xFF3B82F6);
      case 'hard': return const Color(0xFF8B5CF6);
      case 'expert': return const Color(0xFFDD233B);
      default: return const Color(0xFF3B82F6);
    }
  }

  String _getDifficultyText(String diff) {
    switch (diff) {
      case 'easy': return 'Лёгкий';
      case 'medium': return 'Средний';
      case 'hard': return 'Сложный';
      case 'expert': return 'Эксперт';
      default: return diff;
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0 && now.day == date.day) {
        return 'Сегодня, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != date.day)) {
        return 'Вчера, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading || state is HistoryInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFDD233B)));
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<HistoryBloc>().add(HistoryLoadRequested()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is HistoryLoaded) {
            final allGames = state.games;
            final winsList = allGames.where((g) => g['result'] == 'win').toList();
            
            final filtered = _selectedTab == 0 ? allGames : winsList;

            final winsCount = winsList.length;
            final lossesCount = allGames.length - winsCount;
            final totalScore = allGames.fold<int>(0, (s, g) => s + ((g['score'] ?? 0) as int));
            final winRate = allGames.isEmpty ? 0 : (winsCount / allGames.length * 100).round();

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // ── DARK HEADER ──
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text('История игр',
                              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Ваши лучшие партии',
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38)),

                          const SizedBox(height: 24),

                          // Cat + Win rate + stats
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Cat mascot
                              Image.asset(
                                'assets/images/ob_cat.png',
                                width: 90,
                                height: 90,
                              ),
                              const SizedBox(width: 16),

                              // Win rate circle
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: CircularProgressIndicator(
                                        value: winRate / 100,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        valueColor: const AlwaysStoppedAnimation(Color(0xFFDD233B)),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('$winRate%',
                                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                        Text('Побед',
                                            style: GoogleFonts.poppins(fontSize: 9, color: Colors.white54)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Mini stats column
                              Expanded(
                                child: Column(
                                  children: [
                                    _miniStat('$winsCount', 'Побед', const Color(0xFF10B981)),
                                    const SizedBox(height: 8),
                                    _miniStat('$lossesCount', 'Поражений', const Color(0xFFDD233B)),
                                    const SizedBox(height: 8),
                                    _miniStat('$totalScore', 'Очков', const Color(0xFFF59E0B)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── TAB SWITCH ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _tabBtn('Все', 0),
                        _tabBtn('Только победы', 1),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── MOTIVATIONAL QUOTE (cat says) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/ob_cat.png', width: 40, height: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            winsCount >= 5
                                ? 'Мурр! Ты настоящий мастер судоку 🏆'
                                : 'Мурр! Не сдавайся, каждая игра делает тебя лучше! 💪',
                            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0F172A), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Список игр пуст',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),

                // ── GAME CARDS ──
                ...filtered.map((game) => _buildGameCard(game)),

                const SizedBox(height: 100),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _miniStat(String val, String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
        const Spacer(),
        Text(val, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFDD233B) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(dynamic game) {
    final isWin = game['result'] == 'win';
    final String diffRaw = game['difficulty'] ?? 'easy';
    final Color color = _getDifficultyColor(diffRaw);
    final String diffText = _getDifficultyText(diffRaw);
    final String timeText = _formatTime(game['time_elapsed'] ?? 0);
    final String dateText = _formatDate(game['completed_at'] ?? '');
    final int score = game['score'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Icon block
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isWin ? Icons.emoji_events_rounded : Icons.replay_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(diffText,
                          style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isWin ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isWin ? 'Победа' : 'Поражение',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isWin ? const Color(0xFF10B981) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(timeText,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(dateText,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),

          // Score
          if (isWin)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('+$score',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                Text('очков', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              ],
            ),
        ],
      ),
    );
  }
}
