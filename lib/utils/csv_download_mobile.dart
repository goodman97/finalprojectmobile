import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> downloadCSV(
  List<int> bytes,
  String fileName,
) async {
  try {
    Directory? dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    if (dir == null) {
      throw Exception("Directory not found");
    }

    final file = File(
      "${dir.path}/$fileName",
    );

    await file.writeAsBytes(bytes);

    print("CSV saved at: ${file.path}");
  } catch (e) {
    print("CSV SAVE ERROR: $e");
    rethrow;
  }
}