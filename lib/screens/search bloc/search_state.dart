part of 'search_bloc.dart';

@immutable
abstract class SearchState {}

final class SearchInitial extends SearchState {}
final class SearchLoading extends SearchState {}
final class SearchLoaded extends SearchState {
  WallpaperModel mDataModel;
  SearchLoaded({required this.mDataModel});
}
final class SearchError extends SearchState {
  String mError;
  SearchError({required this.mError});
}
