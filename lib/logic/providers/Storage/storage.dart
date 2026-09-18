import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';

Future getDownloadStorage() async {
  Directory downloadDirectory = await getDownloadDirectory();
  return downloadDirectory;
}
