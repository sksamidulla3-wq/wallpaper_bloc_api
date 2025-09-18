part of 'wallpaper_bloc.dart';

@immutable
abstract class WallpaperEvent {}

class TrendingWallpaperFetch extends WallpaperEvent {
  int? page;
  TrendingWallpaperFetch({this.page = 1});

}
