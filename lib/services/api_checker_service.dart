import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiCheckerService {
  Future<Map<bool, String>> checkApi(String incomingUrl) async {
    String url = '$incomingUrl/Connection';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return {true: response.body};
    } else if (response.statusCode == 404) {
      return {false: 'Keycloak URL werd niet gevonden, zie dat deze ingesteld staat in de backend.'};
    } else {
      return {false: 'Er ging iets fout, check de backend logs voor meer informatie.'};
    }
  }
}
