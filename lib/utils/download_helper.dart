// Public API that chooses the correct implementation depending on platform.
export 'download_helper_io.dart'
    if (dart.library.html) 'download_helper_web.dart';
