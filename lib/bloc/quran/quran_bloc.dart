import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/bloc/quran/quran_event.dart';
import 'package:vakit/bloc/quran/quran_state.dart';
import 'package:quran/quran.dart';
import 'package:string_validator/string_validator.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  List<dynamic> _originalSurahs = [];

  QuranBloc() : super(QuranInitial()) {
    on<LoadQuranData>(_onLoadQuranData);
    on<SearchQuran>(_onSearchQuran);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadQuranData(LoadQuranData event, Emitter<QuranState> emit) async {
    try {
      emit(QuranLoading());
      
      // Simulate loading delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));
      
      final String jsonString = await rootBundle.loadString('assets/json/surahs.json');
      final data = jsonDecode(jsonString) as List<dynamic>;
      
      _originalSurahs = data;
      
      emit(QuranLoaded(
        surahs: data,
        filteredSurahs: data,
      ));
    } catch (e) {
      emit(QuranError('Error loading quran ${e.toString()}'));
    }
  }

  Future<void> _onSearchQuran(SearchQuran event, Emitter<QuranState> emit) async {
    if (state is! QuranLoaded) return;
    
    final currentState = state as QuranLoaded;
    
    if (event.query.isEmpty) {
      emit(currentState.copyWith(
        filteredSurahs: _originalSurahs,
        pageNumbers: <int>[],
        ayatResults: null,
        searchQuery: '',
      ));
      return;
    }

    // Handle page number search
    List<int> pageNumbers = [];
    if (event.query.isNotEmpty &&
        isInt(event.query) &&
        toInt(event.query) < 605 &&
        toInt(event.query) > 0) {
  pageNumbers.add(toInt(event.query).toInt());
    }

    // Handle text search
    List<dynamic> filteredSurahs = _originalSurahs;
    dynamic ayatResults;

    if (event.query.length > 3 || event.query.contains(" ")) {
      // Search in verses
      try {
        ayatResults = searchWords(event.query);
      } catch (e) {
        // Handle search error gracefully
        ayatResults = null;
      }

      // Search in surah names
      filteredSurahs = _originalSurahs.where((sura) {
        final suraName = sura['englishName'].toLowerCase();
        final suraNameArabic = getSurahNameArabic(sura["number"]);

        return suraName.contains(event.query.toLowerCase()) ||
            suraNameArabic.contains(event.query.toLowerCase());
      }).toList();
    }

    emit(currentState.copyWith(
      filteredSurahs: filteredSurahs,
      pageNumbers: pageNumbers,
      ayatResults: ayatResults,
      searchQuery: event.query,
    ));
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<QuranState> emit) async {
    if (state is! QuranLoaded) return;
    
    final currentState = state as QuranLoaded;
    emit(currentState.copyWith(
      filteredSurahs: _originalSurahs,
      pageNumbers: <int>[],
      ayatResults: null,
      searchQuery: '',
    ));
  }
}
