import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/sudoku/sudoku_generator.dart';
import 'game_page.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Text('Новая Игра', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text('Выберите режим или уровень', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),

          // AI Coach Card
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage(difficulty: Difficulty.easy, isAICoachMode: true)));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/ob_cat.png', width: 60, height: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('AI-КОУЧ', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ),
                        const SizedBox(height: 6),
                        Text('Начать с нуля', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('ИИ объяснит каждый шаг', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Выбрать сложность', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
          ),
          const SizedBox(height: 12),

          _diffRow(context, 'Лёгкий', 'Разминка', Difficulty.easy, const Color(0xFF10B981), Icons.sentiment_satisfied_alt),
          _diffRow(context, 'Средний', 'Тренировка', Difficulty.medium, const Color(0xFF3B82F6), Icons.psychology_outlined),
          _diffRow(context, 'Сложный', 'Испытание', Difficulty.hard, const Color(0xFF8B5CF6), Icons.bolt),
          _diffRow(context, 'Эксперт', 'Для профи', Difficulty.expert, const Color(0xFFDD233B), Icons.local_fire_department_outlined),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _diffRow(BuildContext context, String title, String sub, Difficulty diff, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(difficulty: diff)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
              Text(sub, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
            ])),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
