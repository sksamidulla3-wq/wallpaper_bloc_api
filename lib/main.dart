import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallpaper_bloc_api/screens/previewpage.dart';
import 'package:wallpaper_bloc_api/screens/search%20bloc/search_bloc.dart';
import 'package:wallpaper_bloc_api/screens/searchUI.dart';
import 'bloc/wallpaper_bloc.dart';
import 'data source/local/db.dart';
import 'data source/remote/api helper.dart';
import 'models/catModel.dart';
import 'models/color model.dart';
import 'models/models.dart';

void main() {
  runApp(
    BlocProvider(
      create: (ctx) => WallpaperBloc(apiHelper: ApiHelper()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();
  Future<WallpaperModel?>? wallpaperModel;
  Future<WallpaperModel?>? bestOfTheMonthWallpaper;
  List<PhotosModel> wallpaperModelList = [];
  List<CategoryModel> categoryModel = [
    CategoryModel(
      title: "Nature",
      imgUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLEHswHVyxjQ-muQA6Te6teY_DxAw-cOm-gA&s",
    ),
    CategoryModel(
      title: "Cars",
      imgUrl:
          "https://www.autoshippers.co.uk/blog/wp-content/uploads/bugatti-centodieci.jpg",
    ),
    CategoryModel(
      title: "Animals",
      imgUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE7qjXvzX0T--7cCogC6yAB8YCjjlbP2ROow&s",
    ),
    CategoryModel(
      title: "Mountains",
      imgUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMuRviGmuOIjiaBd9elsOJ9lthIA9hKV6JGQ&s",
    ),
    CategoryModel(
      title: "Buildings",
      imgUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOgN0_l29D8o4EX2RQJCg-9Taec4S0eBxUKQ&s",
    ),
    CategoryModel(
      title: "Lakes",
      imgUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyqw9Mg0glS6UYJlyYiByGavArF7Q8UjjGLQ&s",
    ),
  ];
  ScrollController? scrollController;
  int page = 0;
  num? totalPages;

  List<ColorModel> colorModel = [
    ColorModel(colorValue: Colors.white, colorCode: "white"),
    ColorModel(colorValue: Colors.black, colorCode: "black"),
    ColorModel(colorValue: Colors.red, colorCode: "red"),
    ColorModel(colorValue: Colors.green, colorCode: "green"),
    ColorModel(colorValue: Colors.blue, colorCode: "blue"),
    ColorModel(colorValue: Colors.yellow, colorCode: "yellow"),
    ColorModel(colorValue: Colors.orange, colorCode: "orange"),
    ColorModel(colorValue: Colors.purple, colorCode: "purple"),
    ColorModel(colorValue: Colors.pink, colorCode: "pink"),
    ColorModel(colorValue: Colors.brown, colorCode: "brown"),
    ColorModel(colorValue: Colors.grey, colorCode: "grey"),
    ColorModel(colorValue: Colors.teal, colorCode: "teal"),
    ColorModel(colorValue: Colors.indigo, colorCode: "indigo"),
    ColorModel(colorValue: Colors.lime, colorCode: "lime"),
  ];

  @override
  void initState() {
    super.initState();
    // fetch first page automatically

    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController!.position.pixels ==
            scrollController!.position.maxScrollExtent) {
          if (totalPages != null && totalPages! > page) {
            page++;
            BlocProvider.of<WallpaperBloc>(
              context,
            ).add(TrendingWallpaperFetch(page: page));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("No More Results")));
          }
        }
      });

    BlocProvider.of<WallpaperBloc>(
      context,
    ).add(TrendingWallpaperFetch(page: page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          theSearchBox(),
          const Text(
            "Color Tone",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          theColorToneTiles(),
          const Text(
            "Best of the month",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bestofMonthView(),
          const Text(
            "Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          wallpaperView(),
        ],
      ),
    );
  }

  Widget bestofMonthView() {
    return BlocListener<WallpaperBloc, WallpaperState>(
      listener: (context, state) {
        if (state is WallpaperLoaded) {
          totalPages = state.mDataModel.total_results! % 15 == 0
              ? state.mDataModel.total_results! ~/ 15
              : state.mDataModel.total_results! ~/ 15 + 1;
          wallpaperModel = Future.value(state.mDataModel);
          if (page == 1) {
            wallpaperModelList.clear();
          }
          wallpaperModelList.addAll(state.mDataModel.photos!);
          setState(() {});
        }
        if (state is WallpaperError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.mError)));
        }
        if (state is WallpaperLoading) {
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
              flex: 1,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: wallpaperModelList.length,
                itemBuilder: (_, index) {
                  var photo = wallpaperModelList[index].src!.portrait!;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewPage(wallpaperUrl: photo),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 0.7),
                          image: DecorationImage(
                            image: NetworkImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Padding theColorToneTiles() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: colorModel.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) {
                      return BlocProvider(
                        create: (ctx) => SearchBloc(
                          apiHelper: ApiHelper(),
                          appDataBase: AppDataBase.instance,
                        ),
                        child: SearchScreen(
                          SearchData: searchController.text.toString(),
                          color: colorModel[index].colorCode!,
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: colorModel[index].colorValue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 0.7),
                  // rectangle with rounded corners
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Padding theSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Find Wallpaper",
          prefixIcon: IconButton(
            onPressed: () {
              String query = searchController.text.trim();
              String safeQuery = Uri.encodeComponent(query);
              if (searchController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) {
                      return BlocProvider(
                        create: (ctx) => SearchBloc(
                          apiHelper: ApiHelper(),
                          appDataBase: AppDataBase.instance,
                        ),
                        child: SearchScreen(
                          SearchData: safeQuery.isNotEmpty ? safeQuery : "",
                        ),
                      );
                    },
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please Enter Something")),
                );
              }
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
      ),
    );
  }

  Widget wallpaperView() {
    return Expanded(
      flex: 2,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: categoryModel.length,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return BlocProvider(
                        create: (ctx) => SearchBloc(
                          apiHelper: ApiHelper(),
                          appDataBase: AppDataBase.instance,
                        ),
                        child: SearchScreen(
                          SearchData: categoryModel[index].title.toString(),
                          isCategory: true,
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 0.7),
                  image: DecorationImage(
                    image: NetworkImage(categoryModel[index].imgUrl.toString()),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Text(
                    categoryModel[index].title.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
