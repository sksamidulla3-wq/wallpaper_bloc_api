part of 'wallpaper_bloc.dart';

@immutable
abstract class WallpaperState {}

final class WallpaperInitial extends WallpaperState {}

final class WallpaperLoading extends WallpaperState {}

final class WallpaperLoaded extends WallpaperState {
  WallpaperModel mDataModel;

  WallpaperLoaded({required this.mDataModel});
}

final class WallpaperError extends WallpaperState {
  String mError;

  WallpaperError({required this.mError});
}
