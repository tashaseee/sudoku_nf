import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../../core/sudoku/sudoku_generator.dart';

class GamePage extends StatelessWidget {
  final Difficulty difficulty;
  final bool isAICoachMode;

  const GamePage({Key? key, required this.difficulty, this.isAICoachMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(NewGameEvent(difficulty)),
      child: GameView(isAICoachMode: isAICoachMode),
    );
  }
}

class GameView extends StatefulWidget {
  final bool isAICoachMode;
  const GameView({Key? key, this.isAICoachMode = false}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  String _coachMessage = '';
  bool _coachVisible = false;
  int _coachStep = 0;
  late AnimationController _coachAnimCtrl;
  late Animation<double> _coachSlide;

  // AI Coach steps (educational flow)
  final List<String> _coachIntroSteps = [
    'Привет! Я твой AI-коуч 🐱\n\nСудоку — это логика. Главное правило: каждая цифра от 1 до 9 должна встречаться ровно один раз в каждой строке, столбце и квадрате 3×3.',
    'Нажми на любую пустую клетку и посмотри — я подсвечу её строку, столбец и блок. Это поможет тебе понять, каких цифр там не хватает.',
    'Начнём с простого хода! Я нашёл клетку, где возможна только одна цифра. Нажми кнопку ниже — и я покажу тебе что делать.',
  ];

  @override
  void initState() {
    super.initState();
    _coachAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _coachSlide = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _coachAnimCtrl, curve: Curves.easeOutCubic));

    if (widget.isAICoachMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroStep(0));
    }
  }

  @override
  void dispose() {
    _coachAnimCtrl.dispose();
    super.dispose();
  }

  void _showIntroStep(int step) {
    if (step >= _coachIntroSteps.length) return;
    setState(() {
      _coachStep = step + 1;
      _coachMessage = _coachIntroSteps[step];
      _coachVisible = true;
    });
    _coachAnimCtrl.forward(from: 0);
  }

  void _dismissCoach(BuildContext context) {
    setState(() => _coachVisible = false);
    context.read<GameBloc>().add(DismissAICoachEvent());
  }

  void _requestCoachHint(BuildContext context, GameState state) {
    context.read<GameBloc>().add(RequestAICoachEvent());
    setState(() => _coachStep++);
  }

  String _diffName(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return 'Лёгкий';
      case Difficulty.medium: return 'Средний';
      case Difficulty.hard: return 'Сложный';
      case Difficulty.expert: return 'Эксперт';
    }
  }

  Color _diffColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return const Color(0xFF10B981);
      case Difficulty.medium: return const Color(0xFF3B82F6);
      case Difficulty.hard: return const Color(0xFF8B5CF6);
      case Difficulty.expert: return const Color(0xFFDD233B);
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.won) _showWinDialog(context, state);
        if (state.aiCoachMessage != null && state.aiCoachMessage != _coachMessage) {
          setState(() {
            _coachMessage = state.aiCoachMessage!;
            _coachVisible = true;
          });
          _coachAnimCtrl.forward(from: 0);
        }
      },
      listenWhen: (p, c) => p.status != c.status || p.aiCoachMessage != c.aiCoachMessage,
      builder: (context, state) {
        final dc = _diffColor(state.difficulty);
        final mistakesLeft = 3 - state.mistakes;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // ── TOP BAR ──
                    _buildTopBar(context, state, dc),

                    // ── STATS ──
                    _buildStatsRow(context, state, mistakesLeft),

                    const SizedBox(height: 10),

                    // ── BOARD ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const SudokuBoard(),
                      ),
                    ),

                    // ── COACH BUTTON ──
                    _buildCoachButton(context, state),

                    // ── NUMBER PAD ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: const NumberPad(),
                    ),
                  ],
                ),
                
                // ── AI COACH BANNER (OVERLAY) ──
                if (_coachVisible)
                  Positioned(
                    top: 130, // Approx below top bar and stats
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCoachBanner(context, state),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext ctx, GameState state, Color dc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)]),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Судоку', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dc, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(_diffName(state.difficulty), style: GoogleFonts.poppins(fontSize: 12, color: dc, fontWeight: FontWeight.w600)),
                    if (widget.isAICoachMode) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text('AI-Коуч', style: GoogleFonts.poppins(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(_formatTime(state.timeElapsed), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext ctx, GameState state, int mistakesLeft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Mistakes (hearts)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    i < mistakesLeft ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: i < mistakesLeft ? const Color(0xFFDD233B) : Colors.grey.shade200,
                    size: 20,
                  ),
                )),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Hint
          GestureDetector(
            onTap: () => ctx.read<GameBloc>().add(UseHintEvent()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 6),
                  Text('Подсказка', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Notes toggle
          GestureDetector(
            onTap: () => ctx.read<GameBloc>().add(ToggleNotesModeEvent()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: state.notesMode ? const Color(0xFFDD233B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: state.notesMode ? Colors.white : Colors.grey.shade500, size: 20),
                  if (state.notesMode) ...[
                    const SizedBox(width: 4),
                    Text('Вкл', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachBanner(BuildContext ctx, GameState state) {
    return SlideTransition(
      position: _coachSlide.drive(Tween(begin: const Offset(0, -0.3), end: Offset.zero)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cat mascot
            Image.asset('assets/images/ob_cat.png', width: 52, height: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('AI-Коуч', style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('Шаг $_coachStep', style: GoogleFonts.poppins(fontSize: 9, color: Colors.white60)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _coachMessage,
                    style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white.withOpacity(0.92), height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _dismissCoach(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text('Понятно!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (widget.isAICoachMode && _coachStep <= _coachIntroSteps.length) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_coachStep < _coachIntroSteps.length) {
                              _showIntroStep(_coachStep);
                            } else {
                              _requestCoachHint(ctx, state);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                            child: Text('Дальше →', style: GoogleFonts.poppins(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachButton(BuildContext ctx, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => _requestCoachHint(ctx, state),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/ob_cat.png', width: 28, height: 28),
              const SizedBox(width: 10),
              Text('Следующий ход от AI-коуча', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showWinDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/ob_cat.png', width: 80, height: 80),
              const SizedBox(height: 12),
              Text('Мурр! Победа!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text('Головоломка решена', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    _winStat('⏱ ${_formatTime(state.timeElapsed)}', 'Время'),
                    _winStat('❌ ${state.mistakes}', 'Ошибки'),
                    _winStat('💡 ${state.hintsUsed}', 'Подсказки'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDD233B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Отлично! 🎉', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _winStat(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(val, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
