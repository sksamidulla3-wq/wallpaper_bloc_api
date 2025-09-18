import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper/wallpaper.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class PreviewPage extends StatelessWidget {
  final String wallpaperUrl;

  const PreviewPage({super.key, required this.wallpaperUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper preview
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(wallpaperUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Action buttons
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Save button
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(
                          "Save the wallpaper to gallery",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                saveWallpaper();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Wallpaper saved to gallery"),
                                  ),
                                );
                              },
                              child: Text("yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("no"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Info button (future use)
                TextButton(
                  onPressed: () {
                    // Handle info button press
                    showDialog(
                      context: context,
                      builder: (ctx) => const AlertDialog(
                        title: Text(
                          "Info",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "This is a wallpaper preview",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Info",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Apply button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(
                          "Apply to ?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                applyWallpaper(context, choice: 0);
                                Navigator.pop(context);
                              },
                              child: Text("Home Screen"),
                            ),
                            TextButton(
                              onPressed: () {
                                applyWallpaper(context, choice: 1);
                                Navigator.pop(context);
                              },
                              child: Text("Lock Screen"),
                            ),
                            TextButton(
                              onPressed: () {
                                applyWallpaper(context, choice: 2);
                                Navigator.pop(context);
                              },
                              child: Text("Both Screen"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Apply"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Save wallpaper to gallery using gal
  Future<void> saveWallpaper() async {
    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(wallpaperUrl));
      if (response.statusCode != 200) {
        throw Exception("Failed to load image");
      }

      // 2. Convert response bytes → Uint8List
      Uint8List bytes = response.bodyBytes;

      // 3. Decode to image (optional: only if you need to re-encode)
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception("Image decoding failed");

      // 4. Encode back to JPEG
      final jpegBytes = Uint8List.fromList(img.encodeJpg(decoded));

      // 5. Save using gal
      await Gal.putImageBytes(jpegBytes, album: "Wallpaper App");

      print("✅ Image saved to gallery");
    } catch (e) {
      print("❌ Save failed: $e");
    }
  }

  // ✅ Apply wallpaper using wallpaper package
  void applyWallpaper(BuildContext context, {int? choice}) {
    var imgStream = Wallpaper.imageDownloadProgress(wallpaperUrl);
    imgStream.listen(
      (event) {
        print("Download progress: $event");
      },
      onDone: () async {
        var result;
       if( choice == 0){
          result = await Wallpaper.homeScreen(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           options: RequestSizeOptions.resizeFit,
         );
       }else if(choice == 1){
         result = await Wallpaper.lockScreen(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           options: RequestSizeOptions.resizeFit,
         );
       }else{
         result = await Wallpaper.bothScreen(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           options: RequestSizeOptions.resizeFit,
         );
       }
        print("✅ Applied: $result");
      },
      onError: (error) {
        print("❌ Error: $error");
      },
    );
  }
}
