import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class BaseRepository {
  String get apiKey => AppConfig.apiKey;
  String get baseUrl => AppConfig.baseUrl;
  List<String> get helperServers => AppConfig.helperServers;

  Future<String> executeRequest(String primaryUrl) async {
    try {
      final response = await http
          .get(Uri.parse(primaryUrl))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw HttpException(
          'خطای سرور با کد ${response.statusCode}',
          uri: Uri.parse(primaryUrl),
        );
      }
    } catch (primaryException) {
      for (String helperServer in helperServers) {
        try {
          final helperUrl = primaryUrl.replaceFirst(
            RegExp(r'^https?://[^/]+'),
            helperServer,
          );
          final response = await http
              .get(Uri.parse(helperUrl))
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            return response.body;
          }
        } catch (_) {
          continue;
        }
      }
      rethrow;
    }
  }
}
