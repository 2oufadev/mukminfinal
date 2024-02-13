import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static Future getData(String url, {Map<String, String>? headers}) async {
    var result;

    if (headers != null) {}

    try {
      http.Response response = await http.get(Uri.parse(url), headers: headers);

      result = handleResponse(response);
    } catch (e) {
      print(url);
      print(e.toString());

      result = handleResponse();
    }

    return result;
  }

  static Future postData(String url,
      {Map<String, String>? headers, Object? body}) async {
    var result;
    print('Http.Post Url: $url');
    if (headers != null) {
      print('Http.Post Headers: $headers');
    }
    if (body != null) {
      print('Http.Post Body: $body');
    }

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      result = handleResponse(response);
      print('Http.Post Response Code: ${response.statusCode}');
      print('Http.Post Response Body: ${response.body}');
    } catch (e) {
      result = handleResponse();
      print('Http.Post Error: $e');
      print('Http.Post Response Body: $result');
    }

    return result;
  }

  static dynamic handleResponse([http.Response? response]) async {
    var result;
    try {
      if (response != null) {
        if (response.statusCode == 200) {
          var temp = jsonDecode(response.body);
          result = {'status': true, 'data': temp};
        } else {
          result = {'status': false, 'message': response.reasonPhrase};
        }
      } else {
        result = {'status': false, 'message': 'Unable to Connect to Server!'};
      }
    } catch (e) {
      print('Handle Response Error: $e');
      result = {'status': false, 'message': 'Something went Wrong!'};
    }

    return result;
  }
}
