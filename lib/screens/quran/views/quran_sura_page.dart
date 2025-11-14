// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:vakit/screens/quran/views/quranScreen.dart';
// import 'package:vakit/utlis/thems/colors.dart';
// // import 'package:quran/dart';
// import 'package:quran/quran.dart';
// import 'package:easy_container/easy_container.dart';
// import 'package:string_validator/string_validator.dart';

// import '../../../models/sura.dart';

// class QuranPage extends StatefulWidget {

//   QuranPage({super.key});

//   @override
//   State<QuranPage> createState() => _QuranPageState();
// }

// class _QuranPageState extends State<QuranPage> {
//   TextEditingController textEditingController = TextEditingController();

//   bool isLoading = true;

//   var searchQuery = "";
//   var filteredData;
//   List<Surah> surahList = [];
//   var ayatFiltered;

//   List pageNumbers = [];
//   var suraJsonData;

//   addFilteredData() async {
//     await Future.delayed(const Duration(milliseconds: 600));
//     setState(() {
//       filteredData = suraJsonData;
//       isLoading = false;
//     });
//   }

//   loadJsonAsset() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/json/surahs.json');
//     var data = jsonDecode(jsonString);
//     setState(() {
//       suraJsonData = data;
//     });
//   }


//   @override
//   void initState() {
//             loadJsonAsset();

//     addFilteredData();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:Colors.white,
   
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : ListView(
//               shrinkWrap: true,
//               physics: const ClampingScrollPhysics(),
//               children: [
//                 TextField(
//                   textDirection: TextDirection.rtl,
//                   controller: textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       searchQuery = value;
//                     });

//                     if (value == "") {
//                       filteredData = suraJsonData;

//                       pageNumbers = [];

//                       setState(() {});
//                     }

//                     if (searchQuery.isNotEmpty &&
//                         isInt(searchQuery) &&
//                         toInt(searchQuery) < 605 &&
//                         toInt(searchQuery) > 0) {
//                       pageNumbers.add(toInt(searchQuery));
//                     }

//                     if (searchQuery.length > 3 ||
//                         searchQuery.toString().contains(" ")) {
//                       setState(() {
//                         ayatFiltered = [];

//                         ayatFiltered = searchWords(searchQuery);
//                         filteredData = suraJsonData.where((sura) {
//                           final suraName = sura['englishName'].toLowerCase();
//                           // final suraNameTranslated =
//                           //     sura['name']
//                           //         .toString()
//                           //         .toLowerCase();
//                           final suraNameTranslated =
//                               getSurahNameArabic(sura["number"]);

//                           return suraName.contains(searchQuery.toLowerCase()) ||
//                               suraNameTranslated
//                                   .contains(searchQuery.toLowerCase());
//                         }).toList();
//                       });
//                     }
//                   },
//                   style: const TextStyle(color: Color.fromARGB(190, 0, 0, 0)),
//                   decoration: const InputDecoration(
//                     hintText: 'searchQuran',
//                     hintStyle: TextStyle(),
//                     border: InputBorder.none,
//                   ),
//                 ),
//                 if (pageNumbers.isNotEmpty)
//                   Container(
//                     child: const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("page"),
//                     ),
//                   ),
//                 ListView.separated(
//                     reverse: true,
//                     itemBuilder: (ctx, index) {
//                       return Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: EasyContainer(
//                           onTap: () {},
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(pageNumbers[index].toString()),
//                                 Text(getSurahName(
//                                     getPageData(pageNumbers[index])[0]
//                                         ["surah"]))
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     separatorBuilder: (context, index) => Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Divider(
//                             color: Colors.grey.withOpacity(.5),
//                           ),
//                         ),
//                     itemCount: pageNumbers.length),
//                 ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   separatorBuilder: (context, index) => Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Divider(
//                       color: Colors.grey.withOpacity(.5),
//                     ),
//                   ),
//                   itemCount: filteredData.length,
//                   itemBuilder: (context, index) {
//                     int suraNumber = index + 1;
//                     String suraName = filteredData[index]["englishName"];
//                     String suraNameEnglishTranslated =
//                         filteredData[index]["englishNameTranslation"];
//                     int suraNumberInQuran = filteredData[index]["number"];
                  
//                     int ayahCount = getVerseCount(suraNumber);

//                     return Padding(
//                       padding: const EdgeInsets.all(0.0),
//                       child: Container(
//                         child: ListTile(
//                           leading: SizedBox(
//                             width: 45,
//                             height: 45,
//                             child: Center(
//                               child: Text(
//                                 suraNumber.toString(),
//                                 style: const TextStyle(
//                                     color: AppColors.accent, fontSize: 14),
//                               ),
//                             ),
//                           ) //  Material(

//                           ,
//                           minVerticalPadding: 0,
//                           title: SizedBox(
//                             width: 90,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   suraName,
//                                   style: const TextStyle(
//                                     // fontWeight: FontWeight.bold,
//                                     color: AppColors.primary,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700, // Text color
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           subtitle: Text(
//                             "$suraNameEnglishTranslated ($ayahCount)",
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.withOpacity(.8)),
//                           ),trailing: RichText(text:  TextSpan(text:                suraNumber.toString(),

//                   // textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontFamily: "arsura",
//                     fontSize: 22,color: Colors.black
             
//                   ),
//                 )),
//                           onTap: () async {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (builder) => QuranViewPage(
//                                         shouldHighlightText: false,
//                                         highlightVerse: "",
//                                         jsonData: suraJsonData,
//                                         pageNumber: getPageNumber(
//                                             suraNumberInQuran, 1))));
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 if (ayatFiltered != null)
//                   ListView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: ayatFiltered["occurences"] > 10
//                         ? 10
//                         : ayatFiltered["occurences"],
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.all(6.0),
//                         child: EasyContainer(
//                           color: Colors.white70,
//                           borderRadius: 14,
//                           onTap: () async {},
//                           child: Text(
//                             "سورة ${getSurahNameArabic(ayatFiltered["result"][index]["surah"])} - ${getVerse(ayatFiltered["result"][index]["surah"], ayatFiltered["result"][index]["verse"], verseEndSymbol: true)}",
//                             textDirection: TextDirection.rtl,
//                             style: const TextStyle(
//                                 color: Colors.black, fontSize: 17),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/bloc/quran/quran_bloc.dart';
import 'package:vakit/bloc/quran/quran_event.dart';
import 'package:vakit/bloc/quran/quran_state.dart';
import 'package:vakit/screens/quran/views/quranScreen.dart';
import 'package:vakit/utlis/thems/colors.dart';
import 'package:quran/quran.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
 
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    
 

    // Load data
    context.read<QuranBloc>().add(LoadQuranData());
  }

  @override
  void dispose() {

    _searchController.dispose();
    super.dispose();
  }

  Widget _buildModernSearchBar(QuranBloc bloc) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        onChanged: (value) => bloc.add(SearchQuran(value)),
        onTap: () {
          setState(() => _isSearchFocused = true);
        },
        onSubmitted: (_) => setState(() => _isSearchFocused = false),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: _isSearchFocused ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    bloc.add(ClearSearch());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Loading the Holy Quran...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<QuranBloc>().add(LoadQuranData()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumberCard(int pageNumber, int index, var jsonData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              pageNumber.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          getSurahName(getPageData(pageNumber)[0]["surah"]),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: const Text(
          "Page",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranViewPage(
                shouldHighlightText: false,
                highlightVerse: "",
                jsonData: jsonData,
                pageNumber: pageNumber,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahCard(dynamic sura, int index, var jsonData) {
  int suraNumber = index + 1;
  String suraName = sura["englishName"];
  String suraNameEnglishTranslated = sura["englishNameTranslation"];
  int suraNumberInQuran = sura["number"];
  int ayahCount = getVerseCount(suraNumberInQuran);

  return AnimatedContainer(
    duration: Duration(milliseconds: 400 + (index * 80)),
    curve: Curves.easeOutCubic,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBFF),
            const Color(0xFFF8F9FA),
            const Color(0xFFF1F3F4),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    QuranViewPage(
                  shouldHighlightText: false,
                  highlightVerse: "",
                  jsonData: jsonData,
                  pageNumber: getPageNumber(suraNumberInQuran, 1),
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Modern number indicator
                Hero(
                  tag: 'surah-$suraNumberInQuran',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        suraNumberInQuran.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // English name
                      Text(
                        suraName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Translation and verse count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              suraNameEnglishTranslated,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$ayahCount آیات",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Arabic name and arrow
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Arabic name
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.08),
                            AppColors.primary.withOpacity(0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        getSurahNameArabic(suraNumberInQuran),
                        style: TextStyle(
                          fontFamily: "arsura",
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Modern arrow indicator
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
} Widget _buildAyatCard(dynamic ayatResult, int index, var jsonData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranViewPage(
                shouldHighlightText: true,
                highlightVerse: getVerse(
                  ayatResult["surah"],
                  ayatResult["verse"],
                  verseEndSymbol: false,
                ),
                jsonData: jsonData,
                pageNumber: getPageNumber(ayatResult["surah"], ayatResult["verse"]),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "آية ${ayatResult["verse"]}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "سورة ${getSurahNameArabic(ayatResult["surah"])}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                getVerse(
                  ayatResult["surah"],
                  ayatResult["verse"],
                  verseEndSymbol: true,
                ),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.8,
                  fontFamily: "Amiri",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<QuranBloc, QuranState>(
          listener: (context, state) {
            if (state is QuranLoaded) {
            }
          },
          builder: (context, state) {
            if (state is QuranInitial || state is QuranLoading) {
              return _buildLoadingState();
            }

            if (state is QuranError) {
              return _buildErrorState(state.message);
            }

            if (state is QuranLoaded) {
              return CustomScrollView(
                slivers: [
               
              
                  // Search Bar
                  SliverToBoxAdapter(
                    child: _buildModernSearchBar(context.read<QuranBloc>()),
                  ),
              
                  // Page Numbers Section
                  if (state.pageNumbers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                           
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPageNumberCard(
                          state.pageNumbers[state.pageNumbers.length - 1 - index],
                          index,
                          state.surahs,
                        ),
                        childCount: state.pageNumbers.length,
                      ),
                    ),
                  ],
              
                  // Surah List Section
                  if (state.filteredSurahs.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Sureler",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSurahCard(
                          state.filteredSurahs[index],
                          index,
                          state.surahs,
                        ),
                        childCount: state.filteredSurahs.length,
                      ),
                    ),
                  ],
              
                  // Ayat Results Section
                  if (state.ayatResults != null && state.ayatResults["occurences"] > 0) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber, Colors.amber.withOpacity(0.5)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "نتائج البحث في الآيات (${state.ayatResults["occurences"] > 10 ? "أول 10" : state.ayatResults["occurences"]})",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAyatCard(
                          state.ayatResults["result"][index],
                          index,
                          state.surahs,
                        ),
                        childCount: state.ayatResults["occurences"] > 10
                            ? 10
                            : state.ayatResults["occurences"],
                      ),
                    ),
                  ],
              
                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
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
