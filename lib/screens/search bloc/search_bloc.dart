import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data source/local/db.dart';
import '../../data source/remote/api helper.dart';
import '../../data source/remote/app_exception.dart';
import '../../data source/remote/urls.dart';
import '../../models/models.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  ApiHelper apiHelper;
  AppDataBase appDataBase;
  SearchBloc({required this.apiHelper, required this.appDataBase}) : super(SearchInitial()) {
    on<GetSearchedWallPaperFetch>((event, emit) async {
      emit(SearchLoading());
      try {
        var mainUrl = event.query.isNotEmpty
            ? "${Urls.SEARCH_WALLPAPER_URL}?query=${event.query}&color=${event.colors}&page=${event.page}"
            : "${Urls.SEARCH_WALLPAPER_URL}?query=${event.colors}";
        var rowWallData = await apiHelper.getAPI(mainUrl);

        var wallDataModel = WallpaperModel.fromJson(rowWallData);
        emit(SearchLoaded(mDataModel: wallDataModel));
      } catch (e) {
        emit(SearchError(mError: (e as AppExceptions).toErrorString()));
      }
    });
  }
}
