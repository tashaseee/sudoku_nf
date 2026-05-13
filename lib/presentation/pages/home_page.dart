import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../../core/api/api_client.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<String> _banners = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
  ];

  List<dynamic> _allArticles = [];
  List<dynamic> _filteredArticles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await ApiClient().getArticles();
      setState(() {
        _allArticles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles.where((a) {
          final title = (a['title'] ?? '').toString().toLowerCase();
          final subtitle = (a['subtitle'] ?? '').toString().toLowerCase();
          final search = query.toLowerCase();
          return title.contains(search) || subtitle.contains(search);
        }).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            // ────── Header ──────
            const SizedBox(height: 32),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                String username = 'Игрок';
                if (state is ProfileLoaded) {
                  username = state.user['username'] ?? 'Игрок';
                }
                return Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(color: Color(0xFFDD233B), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Добрый день!', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey)),
                        Text(username, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // ────── Search Bar ──────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Поиск статей...',
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ────── Banners ──────
            if (_searchQuery.isEmpty) ...[
              SizedBox(
                height: (MediaQuery.of(context).size.width - 48) / 2.85,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 1.0),
                  onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        _banners[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (index) {
                  final isActive = _currentBannerIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFDD233B) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),
            ],

            // ────── Articles Header ──────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_searchQuery.isEmpty ? 'Статьи и Новости' : 'Результаты поиска', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                if (_searchQuery.isEmpty)
                  Text('Все', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFDD233B), fontWeight: FontWeight.w500)),
              ],
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFFDD233B))))
            else if (_filteredArticles.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Ничего не найдено', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
              )
            else
              ..._filteredArticles.map((article) => _buildArticleCard(context, article)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, dynamic article) {
    final color = _getColor(article['color'] ?? '#DD233B');
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticlePage(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 92,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article['title'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(article['subtitle'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(article['read_time'] ?? '3 мин', style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Text('Судоку Мастер', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }
}
