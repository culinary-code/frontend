import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiCheckerService {
  Future<Map<bool, String>> checkApi(String incomingUrl) async {
    String url = '$incomingUrl/Connection';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {

        try {
          var body = jsonDecode(response.body);

          if (body['verifier'] != "Culinary Code") {
            return {
              false:
              'Deze URL is niet bereikbaar, controleer of de backend juist is ingesteld.'
            };
          }

          return {true: body['keycloakUrl']};

        } on FormatException catch (e) {
          return {false: 'Deze URL is niet bereikbaar, controleer of de backend juist is ingesteld.'};
        }

      } else if (response.statusCode == 404) {
        return {
          false:
              'Keycloak URL werd niet gevonden, zie dat deze ingesteld staat in de backend.'
        };
      } else {
        return {
          false:
              'Er ging iets fout, check de backend logs voor meer informatie.'
        };
      }
    } on http.ClientException catch (e) {
      return {false: 'Deze URL is niet bereikbaar.'};
    }
  }
}
