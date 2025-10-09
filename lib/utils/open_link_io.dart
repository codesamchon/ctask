import 'package:url_launcher/url_launcher_string.dart';

Future<bool> openLink(String url) async {
  try {
    return await launchUrlString(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
