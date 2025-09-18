import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data source/remote/api helper.dart';
import '../data source/remote/app_exception.dart';
import '../data source/remote/urls.dart';
import '../models/models.dart';

part 'wallpaper_event.dart';

part 'wallpaper_state.dart';

class WallpaperBloc extends Bloc<WallpaperEvent, WallpaperState> {
  ApiHelper apiHelper;

  WallpaperBloc({required this.apiHelper}) : super(WallpaperInitial()) {
    on<TrendingWallpaperFetch>((event, emit) async {
      emit(WallpaperLoading());
      try {
        var rowWallData = await apiHelper.getAPI("${Urls.TRENDING_WALLPAPER_URL}?page=${event.page}");
        var wallDataModel = WallpaperModel.fromJson(rowWallData);
        emit(WallpaperLoaded(mDataModel: wallDataModel));
      } catch (e) {
        emit(WallpaperError(mError: (e as AppExceptions).toString()));
      }
    });
  }
}
