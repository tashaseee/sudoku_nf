import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'play_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/history/history_bloc.dart';
import '../blocs/notifications/notifications_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePageContent(),   // 🔍 поиск/статьи (главная)
    HistoryPage(),       // ⏱ история игр
    NotificationsPage(), // 🔔 уведомления
    ProfilePage(),       // 👤 профиль
  ];

  void _openPlaySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PlayPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc()..add(ProfileLoadRequested())),
        BlocProvider(create: (_) => HistoryBloc()..add(HistoryLoadRequested())),
        BlocProvider(create: (_) => NotificationsBloc()..add(NotificationsLoadRequested())),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        floatingActionButton: FloatingActionButton(
          onPressed: _openPlaySheet,
          backgroundColor: const Color(0xFFDD233B),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.pets, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 12,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.search_rounded, 'Статьи', 0),
                _navItem(Icons.access_time_rounded, 'История', 1),
                const SizedBox(width: 48),
                _navItem(Icons.notifications_none_rounded, 'События', 2),
                _navItem(Icons.person_outline_rounded, 'Профиль', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFDD233B) : const Color(0xFF9CA3AF), size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isActive ? const Color(0xFFDD233B) : const Color(0xFF9CA3AF),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
