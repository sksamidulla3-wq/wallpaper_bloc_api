class AppExceptions implements Exception {
  String title;
  String body;

  AppExceptions({required this.title, required this.body});

  String toErrorString() {
    return "$title\n$body";
  }
  @override
  String toString() {
    return toErrorString();  // important fix
  }
}

class FetchDataException extends AppExceptions {
  FetchDataException({required String body})
    : super(title: "Error During Communication", body: body);
}

class BadRequestException extends AppExceptions {
  BadRequestException({required String body})
    : super(title: "Invalid Request", body: body);
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException({required String body})
    : super(title: "Unauthorised", body: body);
}

class InvalidInputException extends AppExceptions {
  InvalidInputException({required String body})
    : super(title: "Invalid Input", body: body);
}
