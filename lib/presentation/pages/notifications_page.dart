import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/notifications/notifications_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  IconData _getIcon(String name) {
    switch (name) {
      case 'emoji_events_rounded': return Icons.emoji_events_rounded;
      case 'diamond_rounded': return Icons.diamond_rounded;
      case 'local_fire_department_rounded': return Icons.local_fire_department_rounded;
      case 'bolt_rounded': return Icons.bolt_rounded;
      case 'psychology_rounded': return Icons.psychology_rounded;
      case 'stars_rounded': return Icons.stars_rounded;
      case 'military_tech_rounded': return Icons.military_tech_rounded;
      default: return Icons.notifications_active_rounded;
    }
  }

  Color _getColor(String hexCode) {
    if (hexCode.startsWith('#')) {
      final buffer = StringBuffer();
      if (hexCode.length == 7) buffer.write('ff');
      buffer.write(hexCode.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    return const Color(0xFFDD233B);
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0 && now.day == date.day) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != date.day)) {
        return 'Вчера';
      }
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading || state is NotificationsInitial) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFDD233B)));
            }
            if (state is NotificationsError) {
              return Center(child: Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)));
            }

            if (state is NotificationsLoaded) {
              final notifications = state.notifications;
              final unreadCount = notifications.where((n) => n['is_read'] == false).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Уведомления', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                              if (unreadCount > 0)
                                Text('$unreadCount непрочитанных', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFDD233B))),
                            ],
                          ),
                        ),
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: () => context.read<NotificationsBloc>().add(NotificationsMarkAllReadRequested()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDD233B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Прочитать все', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFDD233B), fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (notifications.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text('У вас пока нет уведомлений', style: GoogleFonts.poppins(color: Colors.grey)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          final bool isUnread = n['is_read'] == false;
                          final Color c = _getColor(n['color'] ?? '#DD233B');
                          final IconData icon = _getIcon(n['icon'] ?? '');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUnread ? c.withOpacity(0.04) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isUnread ? Border.all(color: c.withOpacity(0.15)) : null,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
                                  child: Icon(icon, color: c, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(n['title'], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                          ),
                                          if (isUnread)
                                            Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(n['body'], style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                                      const SizedBox(height: 8),
                                      Text(_formatDate(n['created_at']), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
