import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utlis/thems/colors.dart';

// Main Quran Screen - Complete Quran with Pages
class QuranMainScreen extends StatefulWidget {
  const QuranMainScreen({super.key});

  @override
  State<QuranMainScreen> createState() => _QuranMainScreenState();
}

class _QuranMainScreenState extends State<QuranMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadQuranData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadQuranData() async {
    // Load all surahs data
    for (int i = 1; i <= 114; i++) {
      surahs.add({
        'number': i,
        'name': quran.getSurahName(i),
        'nameArabic': quran.getSurahNameArabic(i),
        'verses': quran.getVerseCount(i),
        'place': quran.getPlaceOfRevelation(i),
        'pages': quran.getSurahPages(i),
      });
    }
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildStatsCards(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSurahList(),
                _buildJuzList(),
                _buildPagesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 30),
            Text(
              ' Kutsal Kur\'an Yükleniyor...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Lütfen bekleyin',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kutsal Kur\'an',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '114 Sure - 6236 Ayet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary!, AppColors.primary!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: Icon(Icons.bookmark, color: Colors.white),
          onPressed: () => _showBookmarks(),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('114', 'Sureler', Icons.list_alt, Colors.blue)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('30', 'Cüzler', Icons.collections_bookmark, Colors.orange)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('604', 'Sayfalar', Icons.auto_stories, Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Sureler'),
          Tab(text: 'Cüzler'),
          Tab(text: 'Sayfalar'),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildSurahCard(surah, index);
      },
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary!, AppColors.primary!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${surah['number']}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          surah['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              surah['nameArabic'],
              style: TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 6),
            Row(
              children: [
                _buildChip('${surah['verses']} Ayet', Colors.blue),
                SizedBox(width: 8),
                _buildChip(surah['place'], Colors.orange),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.play_circle_filled, color: AppColors.primary, size: 32),
        onTap: () => _openSurahReader(surah),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (context, index) {
        int juzNumber = index + 1;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$juzNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              '$juzNumber. Cüz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            subtitle: Text(
              'Cüz $juzNumber - Sayfa ${(juzNumber - 1) * 20 + 1}-${juzNumber * 20}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: Icon(Icons.collections_bookmark, color: Colors.orange[600]),
            onTap: () => {},
          ),
        );
      },
    );
  }

  Widget _buildPagesList() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        int pageNumber = index + 1;
        return _buildPageCard(pageNumber);
      },
    );
  }

  Widget _buildPageCard(int pageNumber) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text(
                        '$pageNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Sayfa $pageNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSurahReader(Map<String, dynamic> surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranReaderScreen(
          surahNumber: surah['number'],
          surahName: surah['name'],
          surahNameArabic: surah['nameArabic'],
        ),
      ),
    );
  }

  // void _openJuzReader(int juzNumber) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => JuzReaderScreen(juzNumber: juzNumber),
  //     ),
  //   );
  // }

  // void _openPageReader(int pageNumber) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PageReaderScreen(pageNumber: pageNumber),
  //     ),
  //   );
  // }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔍 Kur\'an\'da Ara'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Ayet veya sure adı girin...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Ara')),
        ],
      ),
    );
  }

  void _showBookmarks() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📚 Yer işaretleri özelliği yakında eklenecek'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// Surah Reader Screen
class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahNameArabic;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surahNameArabic,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageController;
  int currentPage = 0;
  List<int> surahPages = [];
  bool showTranslation = false;
  double fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    surahPages = quran.getSurahPages(widget.surahNumber);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildReaderAppBar(),
      body: Column(
        children: [
          _buildSurahHeader(),
          _buildReaderControls(),
          Expanded(child: _buildPageViewer()),
          _buildBottomControls(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildReaderAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.surahName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.surahNameArabic,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.bookmark_border),
          onPressed: () => {},
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => {},
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => {},
        ),
      ],
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[100]!, Colors.teal[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          if (widget.surahNumber != 1 && widget.surahNumber != 9) // Tevbe haricinde
            SizedBox(height: 16),
          Text(
            widget.surahNameArabic,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8),
          Text(
            '${widget.surahName} Suresi - ${quran.getVerseCount(widget.surahNumber)} Ayet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderControls() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: showTranslation ? Icons.visibility_off : Icons.visibility,
            label: 'Çeviri',
            onTap: () => setState(() => showTranslation = !showTranslation),
          ),
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Dinle',
          onTap: () => {},
          ),
          _buildControlButton(
            icon: Icons.text_fields,
            label: 'Font',
          onTap: () => {},
          ),
          _buildControlButton(
            icon: Icons.palette,
            label: 'Tema',
          onTap: () => {},
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageViewer() {
    return Container(
      margin: EdgeInsets.all(16),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemCount: surahPages.length,
        itemBuilder: (context, index) {
          return _buildQuranPage(surahPages[index]);
        },
      ),
    );
  }

  Widget _buildQuranPage(int pageNumber) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sayfa $pageNumber',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${currentPage + 1}/${surahPages.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.teal[100]),
          
          // Quran Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildPageVerses(pageNumber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageVerses(int pageNumber) {
    List<Widget> verses = [];
    
    // Get verses for this page
    // var versesInPage = quran.getVersesInPage(pageNumber);
    
    //or (var verse in versesInPage) {
    //   verses.add(_buildVerseWidget(verse));
    //   verses.add(SizedBox(height: 16));
    // }
    
    return verses;
  }

  Widget _buildVerseWidget(Map<String, dynamic> verse) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Arabic Text
          Text(
            verse['arabic'] ?? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontSize: fontSize,
              height: 2.0,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          
          // Verse Number
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${verse['surah']}:${verse['verse']}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: AppColors.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark_border, color: AppColors.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: AppColors.primary),
                              onPressed: () => {},

                  ),
                ],
              ),
            ],
          ),
          
          // Translation (if enabled)
          if (showTranslation) ...[
            Divider(color: Colors.teal[200]),
            Text(
              verse['translation'] ?? 'Çeviri yükleniyor...',
              style: TextStyle(
                fontSize: fontSize - 2,
                height: 1.6,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: currentPage > 0 ? () => _previousPage() : null,
          ),
          Expanded(
            child: Slider(
              value: currentPage.toDouble(),
              max: (surahPages.length - 1).toDouble(),
              onChanged: (value) => {},
              activeColor: AppColors.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: currentPage < surahPages.length - 1 ? () =>{} : null,
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

}

      