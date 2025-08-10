
import 'package:equatable/equatable.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<dynamic> surahs;
  final List<dynamic> filteredSurahs;
  final List<int> pageNumbers;
  final dynamic ayatResults;
  final String searchQuery;

  const QuranLoaded({
    required this.surahs,
    required this.filteredSurahs,
    this.pageNumbers = const [],
    this.ayatResults,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [surahs, filteredSurahs, pageNumbers, ayatResults, searchQuery];

  QuranLoaded copyWith({
    List<dynamic>? surahs,
    List<dynamic>? filteredSurahs,
    List<int>? pageNumbers,
    dynamic ayatResults,
    String? searchQuery,
  }) {
    return QuranLoaded(
      surahs: surahs ?? this.surahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      pageNumbers: pageNumbers ?? this.pageNumbers,
      ayatResults: ayatResults ?? this.ayatResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}