import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utilities/app_config_provider.dart';
import 'post_api_provider.dart';

Future<void> fetchAllContent(Function(List) onDataReady) async {
  if (AppContentCache().hasData) {
    onDataReady(AppContentCache().contentArr!);
    return;
  }
  final url = Uri.parse("${AppConfigProvider.apiUrl}common/get_content");
  try {
    final response = await http.get(url);
    print('response.statusCode ${response.statusCode}');
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      print('res ${res['success']}');
      if (res['success'] == true) {
        List data = res['data'];
        AppContentCache().contentArr = data;
        onDataReady(data);
      }
    }
  } catch (e) {
    print("Error fetching content: $e");
  }
}
