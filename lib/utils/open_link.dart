// Conditional export: web uses open_link_web.dart, other platforms use open_link_io.dart
export 'open_link_io.dart' if (dart.library.html) 'open_link_web.dart';
