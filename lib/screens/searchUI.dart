import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallpaper_bloc_api/screens/previewpage.dart';
import 'package:wallpaper_bloc_api/screens/search%20bloc/search_bloc.dart';
import '../models/models.dart';

class SearchScreen extends StatefulWidget {
  String SearchData;
  String? color;
  bool? isCategory;

  SearchScreen({required this.SearchData, this.color, this.isCategory = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController? scrollController;
  WallpaperModel? wallpaperModel;
  TextEditingController searchController = TextEditingController();
  int pageNo = 1;
  List<PhotosModel> wallpaperModelList = [];
  num totalPages = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController!.position.pixels ==
            scrollController!.position.maxScrollExtent) {
          if (totalPages >= pageNo) {
            pageNo++;
            BlocProvider.of<SearchBloc>(context).add(
              GetSearchedWallPaperFetch(
                query: widget.SearchData,
                colors: widget.color ?? "",
                page: pageNo,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No More Results")));
          }
        }
      });

    BlocProvider.of<SearchBloc>(context).add(
      GetSearchedWallPaperFetch(
        query: widget.SearchData,
        colors: widget.color ?? "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCategory! == false
              ? "Searched Wallpapers"
              : "${widget.SearchData} Wallpapers",
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: widget.isCategory == false
                ? TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Find Wallpaper",
                      prefixIcon: IconButton(
                        onPressed: () {
                          String query = searchController.text.trim();
                          String safeQuery = Uri.encodeComponent(query);
                          BlocProvider.of<SearchBloc>(
                            context,
                          ).add(GetSearchedWallPaperFetch(query: safeQuery));
                        },
                        icon: Icon(Icons.search),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : Container(),
          ),
          const SizedBox(height: 10),
          BlocListener<SearchBloc, SearchState>(
            listener: (_, state) {
              if (state is SearchLoaded) {
                totalPages = state.mDataModel.total_results! % 15 == 0
                    ? state.mDataModel.total_results! ~/ 15
                    : state.mDataModel.total_results! ~/ 15 + 1;
                wallpaperModel = state.mDataModel;
                wallpaperModelList.addAll(wallpaperModel!.photos!);
                setState(() {});
              }
              if (state is SearchError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.mError)));
              }
              if (state is SearchLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Loading..."),
                        SizedBox(width: 10),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }
            },
            child: wallpaperModelList.isNotEmpty
                ? Expanded(
                    flex: 3,
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: wallpaperModelList.length,
                      itemBuilder: (ctx, index) {
                        var photos = wallpaperModelList[index].src!.portrait!;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.7,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(photos),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PreviewPage(wallpaperUrl: photos),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
