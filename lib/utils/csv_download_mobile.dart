import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> downloadCSV(
  List<int> bytes,
  String fileName,
) async {
  final dir =
      await getApplicationDocumentsDirectory();

  final file = File(
    "${dir.path}/$fileName",
  );

  await file.writeAsBytes(bytes);

  print(
    "CSV saved at: ${file.path}",
  );
}