// Web implementation — use browser window.open to avoid MissingPlugin on web builds
import 'dart:html' as html;

Future<bool> openLink(String url) async {
  try {
    html.window.open(url, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
