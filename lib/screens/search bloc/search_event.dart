part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class GetSearchedWallPaperFetch extends SearchEvent {
  String query;
  String colors;
  GetSearchedWallPaperFetch({required this.query, this.colors = ""});
}