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
                    await saveWallpaper();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Info button (future use)
                TextButton(
                  onPressed: () {},
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
                    applyWallpaper(context);
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
  void applyWallpaper(BuildContext context) {
    var imgStream = Wallpaper.imageDownloadProgress(wallpaperUrl);
    imgStream.listen((event) {
      print("Download progress: $event");
    }, onDone: () async {
      var result = await Wallpaper.homeScreen(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        options: RequestSizeOptions.resizeFit,
      );
      print("✅ Applied: $result");
    }, onError: (error) {
      print("❌ Error: $error");
    });
  }
}
