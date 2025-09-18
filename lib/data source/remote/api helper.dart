import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wallpaper_bloc_api/data%20source/remote/urls.dart';
import 'app_exception.dart';

class ApiHelper {

  Future<dynamic> getAPI(String url, {Map<String, String>? headers}) async {
    var uri = Uri.parse(url);

    try {
      var response = await http.get(
        uri,
        headers: headers ?? {"Authorization": Urls.API_KEY},
      );
      return returnDataResponse(response);
    } on SocketException{
      /// internet error
      throw FetchDataException(body: "Internet error");
    }
  }

  dynamic returnDataResponse(http.Response resp) {
    switch (resp.statusCode) {
      case 200:

        /// success
        var responseJson = resp.body;
        var data = jsonDecode(responseJson);
        return data;

      case 400:
        throw BadRequestException(body: resp.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(body: resp.body.toString());
      case 500:
        throw InvalidInputException(body: resp.body.toString());
      default:
        throw FetchDataException(
          body:
              "error occurred while communicating with server with status code ${resp.statusCode.toString()}",
        );
    }
  }
}
