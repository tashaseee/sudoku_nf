import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticlePage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticlePage({Key? key, required this.article}) : super(key: key);

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
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(article['color'] ?? '#DD233B');
    final title = article['title'] ?? '';
    final body = article['body'] ?? '';
    final readTime = article['read_time'] ?? '3 мин';
    final date = _formatDate(article['published_at'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with color
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                readTime + ' чтения',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              date,
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildContent(body),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(String content) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.startsWith('## ')) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(
          Text(
            line.replaceFirst('## ', ''),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Text(
            line.replaceAll('**', ''),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
      } else if (line.startsWith('1. ') || line.startsWith('2. ') || line.startsWith('3. ') || line.startsWith('4. ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              line,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ),
        );
      } else if (line.isNotEmpty) {
        widgets.add(
          Text(
            line,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF374151),
              height: 1.7,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }
}
