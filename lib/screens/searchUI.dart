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
  WallpaperModel? wallpaperModel;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: Text(widget.isCategory! == false ? "Searched Wallpapers" : "${widget.SearchData} Wallpapers"), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: widget.isCategory == false ? TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Find Wallpaper",
                prefixIcon: IconButton(
                  onPressed: () {
                    BlocProvider.of<SearchBloc>(context).add(
                      GetSearchedWallPaperFetch(
                        query: searchController.text.toString(),
                      ),
                    );
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
            ) : Container(),
          ),
          const SizedBox(height: 10),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (_, state) {
              if (state is SearchLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SearchError) {
                return Center(child: Text(state.mError));
              } else if (state is SearchLoaded) {
                wallpaperModel = state.mDataModel;
                return wallpaperModel!.photos!.isNotEmpty
                    ? Expanded(
                        flex: 3,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 1,
                              ),
                          itemCount: wallpaperModel!.photos!.length,
                          itemBuilder: (ctx, index) {
                            var photos =
                                wallpaperModel!.photos![index].src!.portrait!;
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
                    : Center(child: Text("No Data Found"));
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
